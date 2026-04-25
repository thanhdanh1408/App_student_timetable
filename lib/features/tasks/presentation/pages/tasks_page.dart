import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core/widgets/app_drawer.dart';

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
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa công việc?'),
        content: const Text('Bạn có chắc muốn xóa công việc này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context.read<TasksViewModel>().delete(id);
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TasksViewModel>();

    final tasks = switch (_filter) {
      'Pending' => vm.pendingTasks,
      'Completed' => vm.completedTasks,
      _ => vm.tasks,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do & Assignments', style: TextStyle(color: Colors.white)),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: _filter == 'All',
                    onSelected: (_) => setState(() => _filter = 'All'),
                  ),
                  ChoiceChip(
                    label: const Text('Pending'),
                    selected: _filter == 'Pending',
                    onSelected: (_) => setState(() => _filter = 'Pending'),
                  ),
                  ChoiceChip(
                    label: const Text('Completed'),
                    selected: _filter == 'Completed',
                    onSelected: (_) => setState(() => _filter = 'Completed'),
                  ),
                ],
              ),
            ),
            if (vm.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (tasks.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: Text('Chưa có công việc. Nhấn + để thêm.')),
              )
            else
              ...tasks.map(
                (task) => TaskCard(
                  task: task,
                  onToggleDone: (value) => vm.toggleCompleted(task, value ?? false),
                  onEdit: () => _showForm(task: task),
                  onDelete: () => _confirmDelete(task.id!),
                ),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
