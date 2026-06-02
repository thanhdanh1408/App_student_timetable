// lib/features/schedule/presentation/pages/schedule_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '/core/l10n/app_localizations.dart';
import '/core/widgets/app_drawer.dart';
import '/core/widgets/shimmer_loading.dart';
import '/core/widgets/empty_state_widget.dart';
import '/core/widgets/error_state_widget.dart';
import '../services/schedule_export_service.dart';
import '../widgets/schedule_card.dart';
import '../widgets/schedule_form_dialog.dart';
import '../providers/schedule_provider.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  final _searchCtrl = TextEditingController();
  final _exportService = ScheduleExportService();
  String _filterDay = 'all';
  bool _isCalendarView = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<(String, String)> _getDayOptions(AppLocalizations l) => [
        ('all', l.all),
        ('mon', l.isVietnamese ? 'Thứ 2' : 'Monday'),
        ('tue', l.isVietnamese ? 'Thứ 3' : 'Tuesday'),
        ('wed', l.isVietnamese ? 'Thứ 4' : 'Wednesday'),
        ('thu', l.isVietnamese ? 'Thứ 5' : 'Thursday'),
        ('fri', l.isVietnamese ? 'Thứ 6' : 'Friday'),
        ('sat', l.isVietnamese ? 'Thứ 7' : 'Saturday'),
        ('sun', l.isVietnamese ? 'Chủ nhật' : 'Sunday'),
      ];

  int _weekdayToScheduleDay(int weekday) {
    // Dart weekday: Mon=1..Sun=7, app convention: Mon=2..Sun=8
    return weekday == DateTime.sunday ? 8 : weekday + 1;
  }

  List<dynamic> _eventsForDay(DateTime day, List schedules) {
    final scheduleDay = _weekdayToScheduleDay(day.weekday);
    return schedules.where((s) => s.dayOfWeek == scheduleDay).toList();
  }

  Future<void> _exportSchedules(List schedules, _ExportType type) async {
    if (schedules.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có lịch học để export.')),
      );
      return;
    }

    try {
      if (type == _ExportType.pdf) {
        final file = await _exportService.exportPdf(schedules.cast());
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Da luu PDF tai: ${file.path}'),
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'CHIA SE',
              onPressed: () {
                _exportService.shareFiles([file], text: 'Thoi khoa bieu - PDF');
              },
            ),
          ),
        );
      } else if (type == _ExportType.ics) {
        final file = await _exportService.exportIcs(schedules.cast());
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Da luu iCal tai: ${file.path}'),
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'CHIA SE',
              onPressed: () {
                _exportService.shareFiles([file], text: 'Thoi khoa bieu - iCal');
              },
            ),
          ),
        );
      } else {
        final pdf = await _exportService.exportPdf(schedules.cast());
        final ics = await _exportService.exportIcs(schedules.cast());
        await _exportService.shareFiles([pdf, ics]);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export thất bại: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showFormDialog({schedule}) {
    final existingSchedules = ref.read(schedulesListProvider).asData?.value ?? [];
    showDialog(
      context: context,
      builder: (_) => ScheduleFormDialog(
        schedule: schedule,
        existingSchedules: existingSchedules,
        onSave: (updatedSchedule) async {
          try {
            if (schedule == null) {
              await ref.read(scheduleControllerProvider.notifier)
                  .addSchedule(updatedSchedule);
            } else {
              await ref.read(scheduleControllerProvider.notifier)
                  .updateSchedule(updatedSchedule);
            }
            ref.invalidate(schedulesListProvider);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(schedule == null
                      ? '✅ Thêm lịch học thành công'
                      : '✅ Cập nhật lịch học thành công'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("❌ Lỗi: ${e.toString()}"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(String scheduleId, String subjectName) {
    final pageContext = context;
    showDialog(
      context: pageContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Xóa lịch học?"),
        content: Text("Bạn có chắc chắn muốn xóa lịch học của \"$subjectName\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Hủy", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ref.read(scheduleControllerProvider.notifier)
                    .deleteSchedule(scheduleId);
                ref.invalidate(schedulesListProvider);
                if (!pageContext.mounted) return;
                ScaffoldMessenger.of(pageContext).showSnackBar(
                  const SnackBar(
                    content: Text("✅ Xóa thành công"),
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                if (!pageContext.mounted) return;
                ScaffoldMessenger.of(pageContext).showSnackBar(
                  SnackBar(
                    content: Text("❌ Lỗi: ${e.toString()}"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final schedulesAsync = ref.watch(schedulesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.schedule, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<_ExportType>(
            icon: const Icon(Icons.ios_share, color: Colors.white),
            tooltip: 'Export/Share',
            onSelected: (value) {
              final data = schedulesAsync.asData?.value ?? [];
              _exportSchedules(data, value);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: _ExportType.pdf,
                child: Text('Export PDF'),
              ),
              PopupMenuItem(
                value: _ExportType.ics,
                child: Text('Export iCal (.ics)'),
              ),
              PopupMenuItem(
                value: _ExportType.share,
                child: Text('Share PDF + iCal'),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              _isCalendarView ? Icons.view_list : Icons.calendar_month,
              color: Colors.white,
            ),
            tooltip: _isCalendarView ? 'Xem dạng danh sách' : 'Xem dạng lịch',
            onPressed: () => setState(() => _isCalendarView = !_isCalendarView),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showFormDialog(),
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/schedule'),
      body: schedulesAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.only(top: 16),
          child: ShimmerListLoading(itemCount: 6, itemHeight: 90),
        ),
        error: (error, stack) => ErrorStateWidget(
          message: l.errorLoadingData,
          detail: error.toString(),
          onRetry: () => ref.invalidate(schedulesListProvider),
        ),
        data: (schedules) {
          var filtered = schedules;

          if (_isCalendarView) {
            final selected = _selectedDay ?? DateTime.now();
            filtered = _eventsForDay(selected, schedules).cast();
          }

          if (_filterDay != 'all') {
            final dayMap = {
              'mon': 2,
              'tue': 3,
              'wed': 4,
              'thu': 5,
              'fri': 6,
              'sat': 7,
              'sun': 8,
            };
            final selectedDay = dayMap[_filterDay]!;
            filtered =
                filtered.where((s) => s.dayOfWeek == selectedDay).toList();
          }

          if (_searchCtrl.text.isNotEmpty) {
            filtered = filtered.where((s) {
              final query = _searchCtrl.text.toLowerCase();
              return (s.subjectName?.toLowerCase().contains(query) ?? false) ||
                  (s.teacherName?.toLowerCase().contains(query) ?? false) ||
                  (s.location?.toLowerCase().contains(query) ?? false);
            }).toList();
          }

          return Column(
            children: [
              if (_isCalendarView)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: TableCalendar<dynamic>(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2035, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        eventLoader: (day) => _eventsForDay(day, schedules),
                        calendarFormat: CalendarFormat.week,
                        availableCalendarFormats: const {
                          CalendarFormat.week: 'Tuần',
                          CalendarFormat.month: 'Tháng',
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                      ),
                    ),
                  ),
                ),
              // Search & Filter
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: l.searchSubjectOrTeacher,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    if (!_isCalendarView)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _getDayOptions(l)
                              .map((day) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text(day.$2),
                                      selected: _filterDay == day.$1,
                                      onSelected: (_) =>
                                          setState(() => _filterDay = day.$1),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
              // List
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: filtered.isEmpty
                      ? EmptyStateWidget(
                          key: const ValueKey('schedule-empty'),
                          icon: Icons.event_busy_outlined,
                          title: l.noSchedule,
                          subtitle: l.isVietnamese
                            ? 'Nhấn nút + để thêm buổi học mới'
                            : 'Tap + to add a new class session',
                          actionLabel: l.addSchedule,
                          onAction: () => _showFormDialog(),
                        )
                      : ListView.builder(
                          key: const ValueKey('schedule-list'),
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewPadding.bottom + 12,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final schedule = filtered[index];
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: Duration(milliseconds: 220 + index * 30),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                final offset = 12 * (1 - value);
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, offset),
                                    child: child,
                                  ),
                                );
                              },
                              child: ScheduleCard(
                                schedule: schedule,
                                onEdit: () => _showFormDialog(schedule: schedule),
                                onDelete: () => _showDeleteConfirmation(
                                  schedule.id ?? "",
                                  schedule.subjectName ?? l.subjects,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

enum _ExportType { pdf, ics, share }