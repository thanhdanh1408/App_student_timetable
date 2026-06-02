import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core/widgets/app_drawer.dart';
import '/core/widgets/shimmer_loading.dart';
import '/core/widgets/empty_state_widget.dart';
import '/core/l10n/app_localizations.dart';

import '../viewmodels/tasks_viewmodel.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form_dialog.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TasksViewModel>().load();
    });
  }

  void _showForm({task}) {
    showDialog(
      context: context,
      builder: (_) => TaskFormDialog(
        task: task,
        onSave: (value) async {
          final vm = context.read<TasksViewModel>();
          if (task == null) {
            await vm.add(value);
          } else {
            await vm.update(value);
          }
        },
      ),
    );
  }

  void _confirmDelete(String id) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.isVietnamese ? 'Xóa công việc?' : 'Delete task?'),
        content: Text(l.isVietnamese ? 'Bạn có chắc muốn xóa công việc này?' : 'Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l.cancel, style: const TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context.read<TasksViewModel>().delete(id);
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
    final vm = context.watch<TasksViewModel>();
    final l = AppLocalizations.of(context);

    final tasks = switch (_filter) {
      'Pending' => vm.pendingTasks,
      'Completed' => vm.completedTasks,
      _ => vm.tasks,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l.tasks, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const AppDrawer(currentRoute: '/tasks'),
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
            // Summary bar
            _TaskSummaryBar(vm: vm),
            // Filter chips
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip(l.isVietnamese ? 'Tất cả' : 'All', 'All', Icons.list_alt),
                  _buildFilterChip(l.isVietnamese ? 'Đang chờ' : 'Pending', 'Pending', Icons.pending_actions),
                  _buildFilterChip(l.isVietnamese ? 'Hoàn thành' : 'Completed', 'Completed', Icons.check_circle_outline),
                ],
              ),
            ),
            // Content
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: vm.isLoading
                  ? const Padding(
                      key: ValueKey('tasks-loading'),
                      padding: EdgeInsets.only(top: 16),
                      child: ShimmerListLoading(itemCount: 5, itemHeight: 80),
                    )
                  : tasks.isEmpty
                      ? Padding(
                          key: const ValueKey('tasks-empty'),
                          padding: const EdgeInsets.only(top: 60),
                          child: EmptyStateWidget(
                            icon: _filter == 'Completed'
                                ? Icons.task_alt
                                : Icons.checklist_rounded,
                            title: _filter == 'Completed'
                              ? l.noCompletedTasks
                                : _filter == 'Pending'
                                ? l.noPendingTasks
                                : l.noTasks,
                            subtitle: _filter == 'All'
                              ? (l.isVietnamese ? 'Nhấn nút + để thêm công việc mới' : 'Tap + to add a new task')
                              : (l.isVietnamese ? 'Thử chuyển sang bộ lọc khác' : 'Try another filter'),
                            actionLabel: _filter == 'All' ? l.addTask : null,
                            onAction: _filter == 'All' ? () => _showForm() : null,
                          ),
                        )
                      : Column(
                          key: const ValueKey('tasks-list'),
                          children: tasks.asMap().entries.map((entry) {
                            final index = entry.key;
                            final task = entry.value;
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
                              child: TaskCard(
                                task: task,
                                onToggleDone: (value) => vm.toggleCompleted(task, value ?? false),
                                onEdit: () => _showForm(task: task),
                                onDelete: () => _confirmDelete(task.id!),
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

  Widget _buildFilterChip(String label, String value, IconData icon) {
    return ChoiceChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      selected: _filter == value,
      onSelected: (_) => setState(() => _filter = value),
    );
  }
}

class _TaskSummaryBar extends StatelessWidget {
  final TasksViewModel vm;

  const _TaskSummaryBar({required this.vm});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final total = vm.tasks.length;
    final pending = vm.pendingTasks.length;
    final completed = vm.completedTasks.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.15),
        border: Border.all(
          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l.progress(completed, total),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatusDot(
                color: Colors.orange,
                label: l.isVietnamese ? '$pending đang chờ' : '$pending pending',
              ),
              const SizedBox(width: 16),
              _StatusDot(
                color: Colors.green,
                label: l.isVietnamese ? '$completed hoàn thành' : '$completed completed',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final Color color;
  final String label;

  const _StatusDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
