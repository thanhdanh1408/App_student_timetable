import 'package:flutter/material.dart';

import '../../domain/entities/task_entity.dart';

class TaskFormDialog extends StatefulWidget {
  final TaskEntity? task;
  final Future<void> Function(TaskEntity task) onSave;

  const TaskFormDialog({super.key, this.task, required this.onSave});

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descriptionCtrl;
  late TextEditingController _notesCtrl;

  String _priority = 'Medium';
  String _status = 'Todo';
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task?.title ?? '');
    _descriptionCtrl = TextEditingController(text: widget.task?.description ?? '');
    _notesCtrl = TextEditingController(text: widget.task?.notes ?? '');

    _priority = widget.task?.priority ?? 'Medium';
    _status = widget.task?.status ?? 'Todo';
    _dueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Chưa chọn';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Thêm công việc' : 'Cập nhật công việc'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề*',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tiêu đề' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(
                  labelText: 'Độ ưu tiên',
                  border: OutlineInputBorder(),
                ),
                items: const ['High', 'Medium', 'Low']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _priority = v ?? 'Medium'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Trạng thái',
                  border: OutlineInputBorder(),
                ),
                items: const ['Todo', 'In Progress', 'Done']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _status = v ?? 'Todo'),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (pickedDate == null) return;
                  if (!context.mounted) return;

                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_dueDate ?? DateTime.now()),
                  );
                  if (pickedTime == null) return;

                  setState(() {
                    _dueDate = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  });
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Hạn chót (deadline)',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(_formatDate(_dueDate)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy', style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;

            final task = TaskEntity(
              id: widget.task?.id,
              title: _titleCtrl.text.trim(),
              description: _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim(),
              priority: _priority,
              status: _status,
              dueDate: _dueDate,
              isCompleted: _status == 'Done',
              notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
              createdAt: widget.task?.createdAt ?? DateTime.now(),
            );

            await widget.onSave(task);
            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
          child: Text(widget.task == null ? 'Thêm' : 'Lưu', style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
