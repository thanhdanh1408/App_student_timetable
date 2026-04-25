import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../subjects/domain/entities/subject_entity.dart';
import '../../../subjects/presentation/viewmodels/subjects_viewmodel.dart';
import '../../domain/entities/grade_entity.dart';

class GradeFormDialog extends StatefulWidget {
  final GradeEntity? grade;
  final Future<void> Function(GradeEntity grade) onSave;

  const GradeFormDialog({super.key, this.grade, required this.onSave});

  @override
  State<GradeFormDialog> createState() => _GradeFormDialogState();
}

class _GradeFormDialogState extends State<GradeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _scoreCtrl;
  late TextEditingController _creditCtrl;
  late TextEditingController _noteCtrl;
  SubjectEntity? _selectedSubject;

  @override
  void initState() {
    super.initState();
    _scoreCtrl = TextEditingController(
      text: widget.grade?.score10.toStringAsFixed(1) ?? '',
    );
    _creditCtrl = TextEditingController(
      text: widget.grade?.credit.toString() ?? '',
    );
    _noteCtrl = TextEditingController(text: widget.grade?.note ?? '');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final subjects = context.read<SubjectsViewModel>().subjects;
    if (_selectedSubject != null || subjects.isEmpty) return;

    if (widget.grade?.subjectId != null) {
      final matched = subjects.where((s) => s.id == widget.grade!.subjectId).toList();
      if (matched.isNotEmpty) {
        _selectedSubject = matched.first;
      }
    }
    _selectedSubject ??= subjects.first;
  }

  @override
  void dispose() {
    _scoreCtrl.dispose();
    _creditCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjects = context.watch<SubjectsViewModel>().subjects;

    return AlertDialog(
      title: Text(widget.grade == null ? 'Thêm điểm môn học' : 'Cập nhật điểm'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<SubjectEntity>(
                value: _selectedSubject,
                decoration: const InputDecoration(
                  labelText: 'Môn học*',
                  border: OutlineInputBorder(),
                ),
                items: subjects
                    .map((s) => DropdownMenuItem<SubjectEntity>(
                          value: s,
                          child: Text(s.subjectName),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedSubject = v),
                validator: (v) => v == null ? 'Vui lòng chọn môn học' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _scoreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Điểm hệ 10*',
                  hintText: 'Ví dụ: 8.5',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final value = double.tryParse(v?.trim() ?? '');
                  if (value == null) return 'Điểm không hợp lệ';
                  if (value < 0 || value > 10) return 'Điểm phải từ 0 đến 10';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _creditCtrl,
                decoration: const InputDecoration(
                  labelText: 'Số tín chỉ*',
                  hintText: 'Ví dụ: 3',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final value = int.tryParse(v?.trim() ?? '');
                  if (value == null) return 'Tín chỉ không hợp lệ';
                  if (value <= 0 || value > 10) return 'Tín chỉ phải từ 1 đến 10';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  hintText: 'Nhập ghi chú (tuỳ chọn)',
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

            final grade = GradeEntity(
              id: widget.grade?.id,
              subjectId: _selectedSubject?.id,
              subjectName: _selectedSubject?.subjectName,
              teacherName: _selectedSubject?.teacherName,
              score10: double.parse(_scoreCtrl.text.trim()),
              credit: int.parse(_creditCtrl.text.trim()),
              note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
              updatedAt: DateTime.now(),
            );

            await widget.onSave(grade);
            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
          child: Text(
            widget.grade == null ? 'Thêm' : 'Lưu',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
