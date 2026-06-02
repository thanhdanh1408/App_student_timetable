import 'package:flutter/material.dart';
import '/core/l10n/app_localizations.dart';
import '../../../../core/utils/validators.dart';

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
    if (date == null) {
      return AppLocalizations.of(context).isVietnamese ? 'Chưa chọn' : 'Not selected';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.task == null
          ? (l.isVietnamese ? 'Thêm công việc' : 'Add task')
          : (l.isVietnamese ? 'Cập nhật công việc' : 'Update task')),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: l.isVietnamese ? 'Tiêu đề*' : 'Title*',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  final result = FormValidator.validateLength(v ?? '', 'Title', 1, 120);
                  return result.isFailure()
                      ? (l.isVietnamese ? 'Tiêu đề tối đa 120 ký tự' : 'Title can be up to 120 characters')
                      : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l.isVietnamese ? 'Mô tả' : 'Description',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  final result = FormValidator.validateOptionalLength(v ?? '', 'Description', 500);
                  return result.isFailure()
                      ? (l.isVietnamese ? 'Mô tả tối đa 500 ký tự' : 'Description can be up to 500 characters')
                      : null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: InputDecoration(
                  labelText: l.isVietnamese ? 'Mức độ ưu tiên' : 'Priority',
                  border: const OutlineInputBorder(),
                ),
                items: const ['High', 'Medium', 'Low']
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(l.isVietnamese ? (p == 'High' ? 'Cao' : p == 'Low' ? 'Thấp' : 'Trung bình') : p),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _priority = v ?? 'Medium'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(
                  labelText: l.isVietnamese ? 'Trạng thái' : 'Status',
                  border: const OutlineInputBorder(),
                ),
                items: const ['Todo', 'In Progress', 'Done']
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(l.isVietnamese ? (s == 'Todo' ? 'Cần làm' : s == 'In Progress' ? 'Đang làm' : 'Hoàn thành') : s),
                        ))
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
                  decoration: InputDecoration(
                    labelText: l.isVietnamese ? 'Hạn chót' : 'Deadline',
                    border: const OutlineInputBorder(),
                  ),
                  child: Text(_formatDate(_dueDate)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l.isVietnamese ? 'Ghi chú' : 'Notes',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  final result = FormValidator.validateOptionalLength(v ?? '', 'Notes', 1000);
                  return result.isFailure()
                      ? (l.isVietnamese ? 'Ghi chú tối đa 1000 ký tự' : 'Notes can be up to 1000 characters')
                      : null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel, style: const TextStyle(color: Colors.black)),
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

            try {
              await widget.onSave(task);
              if (!context.mounted) return;
              Navigator.of(context).pop();
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
              );
            }
          },
          child: Text(widget.task == null ? l.add : l.save, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
