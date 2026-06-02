// lib/features/subjects/presentation/pages/subjects_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import '/core/l10n/app_localizations.dart';
import '/core/widgets/app_drawer.dart';
import '/core/widgets/shimmer_loading.dart';
import '/core/widgets/empty_state_widget.dart';
import '/core/widgets/error_state_widget.dart';
import '../viewmodels/subjects_viewmodel.dart';
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
    final existingSubjects = ref.read(subjectsListProvider).asData?.value ?? [];
    showDialog(
      context: context,
      builder: (_) => SubjectFormDialog(
        subject: subject,
        existingSubjects: existingSubjects,
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
              // Keep Provider-based consumers (Grades/Notes dialogs) in sync.
              provider_pkg.Provider.of<SubjectsViewModel>(context, listen: false).load();
            }
            
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
    final pageContext = context;
    showDialog(
      context: pageContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa môn học'),
        content: Text('Bạn có chắc muốn xóa "${subject.subjectName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                if (subject.id != null) {
                  await ref.read(subjectsControllerProvider.notifier).deleteSubject(subject.id!);

                  // Refresh the list
                  ref.invalidate(subjectsListProvider);
                  if (!pageContext.mounted) return;
                  provider_pkg.Provider.of<SubjectsViewModel>(pageContext, listen: false).load();
                  ScaffoldMessenger.of(pageContext).showSnackBar(
                    const SnackBar(content: Text('✅ Xóa thành công')),
                  );
                }
              } catch (e) {
                if (!pageContext.mounted) return;
                ScaffoldMessenger.of(pageContext).showSnackBar(
                  SnackBar(content: Text('❌ Lỗi: $e'), backgroundColor: Colors.red),
                );
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
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.subjects, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showFormDialog(),
            tooltip: l.addSubject,
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/subjects'),
      body: subjectsAsyncValue.when(
        // Loading state
        loading: () => const Padding(
          padding: EdgeInsets.only(top: 16),
          child: ShimmerListLoading(itemCount: 5, itemHeight: 90),
        ),
        // Error state
        error: (error, stackTrace) => ErrorStateWidget(
          message: 'Lỗi tải dữ liệu',
          detail: error.toString(),
          onRetry: () => ref.refresh(subjectsListProvider),
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
                    hintText: l.searchSubjectOrTeacher,
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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: filteredSubjects.isEmpty
                      ? EmptyStateWidget(
                          key: const ValueKey('subjects-empty'),
                          icon: _searchQuery.isEmpty
                              ? Icons.menu_book_outlined
                              : Icons.search_off,
                          title: _searchQuery.isEmpty
                              ? l.noSubjects
                              : l.noResults,
                          subtitle: _searchQuery.isEmpty
                              ? (l.isVietnamese ? 'Nhấn nút + để thêm môn học' : 'Tap + to add a subject')
                              : l.tryOtherKeyword,
                          actionLabel: _searchQuery.isEmpty ? l.addSubject : null,
                          onAction: _searchQuery.isEmpty ? () => _showFormDialog() : null,
                        )
                      : ListView.builder(
                          key: const ValueKey('subjects-list'),
                          padding: EdgeInsets.fromLTRB(
                            12,
                            12,
                            12,
                            MediaQuery.of(context).viewPadding.bottom + 12,
                          ),
                          itemCount: filteredSubjects.length,
                          itemBuilder: (context, index) {
                            final subject = filteredSubjects[index];
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
                              child: SubjectCard(
                                subject: subject,
                                onEdit: () => _showFormDialog(subject: subject),
                                onDelete: () => _deleteSubject(subject),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}