// lib/features/subjects/presentation/pages/subjects_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subjects_provider.dart';
import '../widgets/subject_card.dart';
import '../widgets/subject_form_dialog.dart';
import '../../domain/entities/subject_entity.dart';

class SubjectsPage extends ConsumerStatefulWidget {
  const SubjectsPage({super.key});

  @override
  ConsumerState<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends ConsumerState<SubjectsPage> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Filter subjects based on search query
  List<SubjectEntity> _filterSubjects(List<SubjectEntity> subjects) {
    if (_searchQuery.isEmpty) return subjects;
    
    return subjects.where((s) {
      final query = _searchQuery.toLowerCase();
      return s.subjectName.toLowerCase().contains(query) ||
          (s.teacherName?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  /// Show add/edit dialog
  void _showFormDialog({SubjectEntity? subject}) {
    showDialog(
      context: context,
      builder: (_) => SubjectFormDialog(
        subject: subject,
        onSave: (updatedSubject) async {
          try {
            if (subject == null) {
              // Add new subject
              await ref.read(subjectsControllerProvider.notifier).addSubject(updatedSubject);
            } else {
              // Update existing subject
              await ref.read(subjectsControllerProvider.notifier).updateSubject(updatedSubject);
            }
            
            // Refresh the list
            ref.invalidate(subjectsListProvider);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(subject == null ? '✅ Thêm thành công' : '✅ Cập nhật thành công'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('❌ Lỗi: $e'), backgroundColor: Colors.red),
              );
            }
          }
        },
      ),
    );
  }

  /// Delete subject with confirmation
  void _deleteSubject(SubjectEntity subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa môn học'),
        content: Text('Bạn có chắc muốn xóa "${subject.subjectName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              try {
                if (subject.id != null) {
                  await ref.read(subjectsControllerProvider.notifier).deleteSubject(subject.id!);
                  
                  // Refresh the list
                  ref.invalidate(subjectsListProvider);
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Xóa thành công')),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ Lỗi: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the subjects list provider
    final subjectsAsyncValue = ref.watch(subjectsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Môn học', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showFormDialog(),
            tooltip: 'Thêm môn học',
          ),
        ],
      ),
      body: subjectsAsyncValue.when(
        // Loading state
        loading: () => const Center(child: CircularProgressIndicator()),
        
        // Error state
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
              const SizedBox(height: 16),
              const Text('Lỗi tải dữ liệu', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text(error.toString(), style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(subjectsListProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        
        // Success state
        data: (subjects) {
          final filteredSubjects = _filterSubjects(subjects);
          
          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Tìm môn học hoặc giảng viên...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              
              // Subject list or empty state
              Expanded(
                child: filteredSubjects.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Chưa có môn học nào'
                                  : 'Không tìm thấy kết quả',
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Nhấn nút + để thêm'
                                  : 'Thử tìm kiếm với từ khóa khác',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredSubjects.length,
                        itemBuilder: (context, index) {
                          final subject = filteredSubjects[index];
                          return SubjectCard(
                            subject: subject,
                            onEdit: () => _showFormDialog(subject: subject),
                            onDelete: () => _deleteSubject(subject),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}