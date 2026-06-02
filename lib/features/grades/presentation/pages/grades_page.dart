import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core/widgets/app_drawer.dart';
import '/core/widgets/shimmer_loading.dart';
import '/core/widgets/empty_state_widget.dart';
import '/core/l10n/app_localizations.dart';

import '../viewmodels/grades_viewmodel.dart';
import '../widgets/grade_card.dart';
import '../widgets/grade_form_dialog.dart';

class GradesPage extends StatefulWidget {
  const GradesPage({super.key});

  @override
  State<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GradesViewModel>().load();
    });
  }

  void _showForm({grade}) {
    showDialog(
      context: context,
      builder: (_) => GradeFormDialog(
        grade: grade,
        onSave: (value) async {
          final vm = context.read<GradesViewModel>();
          if (grade == null) {
            await vm.add(value);
          } else {
            await vm.update(value);
          }
        },
      ),
    );
  }

  void _confirmDelete(String id, String subjectName) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.isVietnamese ? 'Xóa điểm?' : 'Delete grade?'),
        content: Text(l.isVietnamese 
            ? 'Bạn có chắc muốn xóa điểm của môn "$subjectName"?' 
            : 'Are you sure you want to delete the grade for "$subjectName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l.cancel, style: const TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context.read<GradesViewModel>().delete(id);
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
            },
            child: Text(l.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GradesViewModel>();
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.grades, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const AppDrawer(currentRoute: '/grades'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: vm.load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // GPA Overview Card
            _GpaSummaryCard(vm: vm),
            // Content
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: vm.isLoading
                  ? const Padding(
                      key: ValueKey('grades-loading'),
                      padding: EdgeInsets.only(top: 16),
                      child: ShimmerListLoading(itemCount: 4, itemHeight: 80),
                    )
                  : vm.grades.isEmpty
                      ? Padding(
                          key: const ValueKey('grades-empty'),
                          padding: const EdgeInsets.only(top: 60),
                          child: EmptyStateWidget(
                            icon: Icons.school_outlined,
                            title: l.noGrades,
                            subtitle: l.isVietnamese ? 'Nhấn nút + để thêm điểm môn học' : 'Tap + to add a grade',
                            actionLabel: l.addGrade,
                            onAction: () => _showForm(),
                          ),
                        )
                      : Column(
                          key: const ValueKey('grades-list'),
                          children: vm.grades.asMap().entries.map((entry) {
                            final index = entry.key;
                            final g = entry.value;
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: Duration(milliseconds: 250 + index * 40),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 12 * (1 - value)),
                                    child: child,
                                  ),
                                );
                              },
                              child: GradeCard(
                                grade: g,
                                onEdit: () => _showForm(grade: g),
                                onDelete: () => _confirmDelete(g.id!, g.subjectName ?? 'N/A'),
                              ),
                            );
                          }).toList(),
                        ),
            ),
            SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 80),
          ],
        ),
      ),
    );
  }
}

class _GpaSummaryCard extends StatelessWidget {
  final GradesViewModel vm;

  const _GpaSummaryCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.08),
            colorScheme.primary.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colorScheme.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: colorScheme.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                l.gpaOverview,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _GpaItem(
                  label: l.gpa10,
                  value: vm.gpa10.toStringAsFixed(2),
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GpaItem(
                  label: l.gpa4,
                  value: vm.gpa4.toStringAsFixed(2),
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GpaItem(
                  label: l.subjectCount,
                  value: '${vm.grades.length}',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GpaItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _GpaItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
