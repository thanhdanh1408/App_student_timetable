// lib/features/exam/presentation/pages/exam_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/core/l10n/app_localizations.dart';
import '/core/widgets/app_drawer.dart';
import '/core/widgets/shimmer_loading.dart';
import '/core/widgets/empty_state_widget.dart';
import '/core/widgets/error_state_widget.dart';
import '../../domain/entities/exam_entity.dart';
import '../widgets/exam_card.dart';
import '../widgets/exam_form_dialog.dart';
import '../providers/exam_provider.dart';

class ExamPage extends ConsumerStatefulWidget {
  const ExamPage({super.key});

  @override
  ConsumerState<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends ConsumerState<ExamPage> {
  final _searchCtrl = TextEditingController();
  String _filterStatus = 'all';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Combine examDate (midnight) with examTime ("HH:mm") for accurate comparison.
  /// If examTime is missing, assumes end of day (23:59) so the exam stays "upcoming" all day.
  DateTime _combineExamDateTime(ExamEntity e) {
    final date = e.examDate!;
    if (e.examTime != null && e.examTime!.contains(':')) {
      try {
        final parts = e.examTime!.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return DateTime(date.year, date.month, date.day, hour, minute);
      } catch (_) {}
    }
    // Fallback: end of the exam day
    return DateTime(date.year, date.month, date.day, 23, 59);
  }

  void _showFormDialog({ExamEntity? exam}) {
    final existingExams = ref.read(examsListProvider).asData?.value ?? [];
    showDialog(
      context: context,
      builder: (_) => ExamFormDialog(
        exam: exam,
        existingExams: existingExams,
        onSave: (updatedExam) async {
          try {
            if (exam == null) {
              await ref.read(examControllerProvider.notifier)
                  .addExam(updatedExam);
            } else {
              await ref.read(examControllerProvider.notifier)
                  .updateExam(updatedExam);
            }
            ref.invalidate(examsListProvider);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(exam == null
                      ? '✅ Thêm lịch thi thành công'
                      : '✅ Cập nhật lịch thi thành công'),
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

  void _showDeleteConfirmation(String examId, String subjectName) {
    final pageContext = context;
    showDialog(
      context: pageContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Xóa lịch thi?"),
        content: Text("Bạn có chắc chắn muốn xóa lịch thi \"$subjectName\"?"),
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
                await ref.read(examControllerProvider.notifier)
                    .deleteExam(examId);
                ref.invalidate(examsListProvider);
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
    final examsAsync = ref.watch(examsListProvider);
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.exam, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showFormDialog(),
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/exam'),
      body: examsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.only(top: 16),
          child: ShimmerListLoading(itemCount: 5, itemHeight: 90),
        ),
        error: (error, stack) => ErrorStateWidget(
          message: 'Lỗi tải dữ liệu',
          detail: error.toString(),
          onRetry: () => ref.invalidate(examsListProvider),
        ),
        data: (exams) {
          var filtered = exams;

            if (_filterStatus == 'upcoming') {
            filtered = filtered
                .where((e) {
                    if (e.examDate == null) return false;
                    // Combine examDate + examTime for accurate comparison
                    final examDateTime = _combineExamDateTime(e);
                    return examDateTime.isAfter(DateTime.now());
                })
                .toList();
            } else if (_filterStatus == 'past') {
            filtered = filtered
                .where((e) {
                    if (e.examDate == null) return false;
                    final examDateTime = _combineExamDateTime(e);
                    return examDateTime.isBefore(DateTime.now());
                })
                .toList();
          }

          if (_searchCtrl.text.isNotEmpty) {
            filtered = filtered.where((e) {
              final query = _searchCtrl.text.toLowerCase();
              return (e.subjectName?.toLowerCase().contains(query) ?? false) ||
                  (e.teacherName?.toLowerCase().contains(query) ?? false);
            }).toList();
          }

          // Sort by date
          filtered.sort((a, b) {
            if (a.examDate == null || b.examDate == null) return 0;
            return a.examDate!.compareTo(b.examDate!);
          });

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
                        hintText: l.isVietnamese
                          ? 'Tìm môn thi hoặc giảng viên...'
                          : 'Search exam or teacher...',
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
                        children: [
                          ('all', l.all),
                          ('upcoming', l.upcoming),
                          ('past', l.past),
                        ]
                            .map((status) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(status.$2),
                                    selected: _filterStatus == status.$1,
                                    onSelected: (_) =>
                                        setState(() => _filterStatus = status.$1),
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
                          key: const ValueKey('exam-empty'),
                          icon: Icons.quiz_outlined,
                          title: l.noExams,
                          subtitle: l.isVietnamese
                              ? 'Nhấn nút + để thêm lịch thi mới'
                              : 'Tap + to add a new exam',
                          actionLabel: l.addExam,
                          onAction: () => _showFormDialog(),
                        )
                      : ListView.builder(
                          key: const ValueKey('exam-list'),
                          padding: EdgeInsets.fromLTRB(
                            12,
                            12,
                            12,
                            MediaQuery.of(context).viewPadding.bottom + 12,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final exam = filtered[index];
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
                              child: ExamCard(
                                exam: exam,
                                onEdit: () => _showFormDialog(exam: exam),
                                onDelete: () => _showDeleteConfirmation(
                                  exam.id ?? "",
                                  exam.subjectName ?? "Lịch thi",
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
