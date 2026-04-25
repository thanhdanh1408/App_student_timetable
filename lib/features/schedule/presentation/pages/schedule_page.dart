// lib/features/schedule/presentation/pages/schedule_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/core/widgets/app_drawer.dart';
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
  String _filterDay = "Tất cả";

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<String> _getDayNames() =>
      ["Tất cả", "Thứ 2", "Thứ 3", "Thứ 4", "Thứ 5", "Thứ 6", "Thứ 7", "Chủ nhật"];

  void _showFormDialog({schedule}) {
    showDialog(
      context: context,
      builder: (_) => ScheduleFormDialog(
        schedule: schedule,
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xóa lịch học?"),
        content: Text("Bạn có chắc chắn muốn xóa lịch học của \"$subjectName\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await ref.read(scheduleControllerProvider.notifier)
                    .deleteSchedule(scheduleId);
                ref.invalidate(schedulesListProvider);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("✅ Xóa thành công"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("❌ Lỗi: ${e.toString()}"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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
    final schedulesAsync = ref.watch(schedulesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch học", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showFormDialog(),
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/schedule'),
      body: schedulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
              const SizedBox(height: 16),
              const Text("Lỗi tải dữ liệu", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              Text(error.toString(), style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: () => ref.invalidate(schedulesListProvider),
                icon: const Icon(Icons.refresh),
                label: const Text("Tải lại"),
              ),
            ],
          ),
        ),
        data: (schedules) {
          var filtered = schedules;

          if (_filterDay != "Tất cả") {
            final dayMap = {
              "Thứ 2": 2,
              "Thứ 3": 3,
              "Thứ 4": 4,
              "Thứ 5": 5,
              "Thứ 6": 6,
              "Thứ 7": 7,
              "Chủ nhật": 8
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
              // Search & Filter
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: "Tìm môn học hoặc giảng viên...",
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _getDayNames()
                            .map((day) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(day),
                                    selected: _filterDay == day,
                                    onSelected: (_) =>
                                        setState(() => _filterDay = day),
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
                      ? Center(
                          key: const ValueKey('schedule-empty'),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_busy,
                                  size: 80, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              const Text("Chưa có lịch học",
                                  style: TextStyle(fontSize: 20)),
                              const SizedBox(height: 8),
                              const Text("Nhấn nút + để thêm buổi học",
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          key: const ValueKey('schedule-list'),
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
                                  schedule.subjectName ?? "Môn học",
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