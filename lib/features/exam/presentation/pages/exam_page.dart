// lib/features/exam/presentation/pages/exam_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  String _filterStatus = "Tất cả";

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showFormDialog({ExamEntity? exam}) {
    showDialog(
      context: context,
      builder: (_) => ExamFormDialog(
        exam: exam,
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xóa lịch thi?"),
        content: Text("Bạn có chắc chắn muốn xóa lịch thi \"$subjectName\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await ref.read(examControllerProvider.notifier)
                    .deleteExam(examId);
                ref.invalidate(examsListProvider);
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
    final examsAsync = ref.watch(examsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch thi", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showFormDialog(),
          ),
        ],
      ),
      body: examsAsync.when(
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
                onPressed: () => ref.invalidate(examsListProvider),
                icon: const Icon(Icons.refresh),
                label: const Text("Tải lại"),
              ),
            ],
          ),
        ),
        data: (exams) {
          var filtered = exams;

          if (_filterStatus == "Sắp tới") {
            filtered = filtered
                .where((e) =>
                    e.examDate != null && e.examDate!.isAfter(DateTime.now()))
                .toList();
          } else if (_filterStatus == "Đã qua") {
            filtered = filtered
                .where((e) =>
                    e.examDate != null && e.examDate!.isBefore(DateTime.now()))
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
                        hintText: "Tìm môn thi hoặc giảng viên...",
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
                        children: ["Tất cả", "Sắp tới", "Đã qua"]
                            .map((status) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(status),
                                    selected: _filterStatus == status,
                                    onSelected: (_) =>
                                        setState(() => _filterStatus = status),
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
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy,
                                size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            const Text("Chưa có lịch thi nào",
                                style: TextStyle(fontSize: 20)),
                            const SizedBox(height: 8),
                            const Text("Nhấn + để thêm",
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final exam = filtered[index];
                          return ExamCard(
                            exam: exam,
                            onEdit: () => _showFormDialog(exam: exam),
                            onDelete: () => _showDeleteConfirmation(
                              exam.id ?? "",
                              exam.subjectName ?? "Lịch thi",
                            ),
                          );
                        },
                      ),
              )
            ],
          );
        },
      ),
    );
  }
}
