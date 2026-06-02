import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core/l10n/app_localizations.dart';

import '../../../subjects/domain/entities/subject_entity.dart';
import '../../../subjects/presentation/viewmodels/subjects_viewmodel.dart';
import '../../../../core/utils/validators.dart';
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
    final l = AppLocalizations.of(context);
    final subjects = context.watch<SubjectsViewModel>().subjects;

    return AlertDialog(
      title: Text(widget.grade == null
          ? (l.isVietnamese ? 'Thêm điểm môn học' : 'Add grade')
          : (l.isVietnamese ? 'Cập nhật điểm' : 'Update grade')),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<SubjectEntity>(
                value: _selectedSubject,
                decoration: InputDecoration(
                  labelText: l.isVietnamese ? 'Môn học*' : 'Subject*',
                  border: const OutlineInputBorder(),
                ),
                items: subjects
                    .map((s) => DropdownMenuItem<SubjectEntity>(
                          value: s,
                          child: Text(s.subjectName),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedSubject = v),
                validator: (v) => v == null
                    ? (l.isVietnamese ? 'Vui lòng chọn môn học' : 'Please select a subject')
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _scoreCtrl,
                decoration: InputDecoration(
                  labelText: l.isVietnamese ? 'Điểm (hệ 10)*' : 'Score (10-point)*',
                  hintText: '8.5',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final value = double.tryParse(v?.trim() ?? '');
                  if (value == null) {
                    return l.isVietnamese ? 'Điểm không hợp lệ' : 'Invalid score';
                  }
                  final rangeResult = FormValidator.validateNumberRange(value, 'Score', 0, 10);
                  if (rangeResult.isFailure()) {
                    return l.isVietnamese ? 'Điểm phải từ 0 đến 10' : 'Score must be between 0 and 10';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _creditCtrl,
                decoration: InputDecoration(
                  labelText: l.isVietnamese ? 'Số tín chỉ*' : 'Credits*',
                  hintText: '3',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final value = int.tryParse(v?.trim() ?? '');
                  if (value == null) {
                    return l.isVietnamese ? 'Tín chỉ không hợp lệ' : 'Invalid credits';
                  }
                  if (value <= 0 || value > 10) {
                    return l.isVietnamese ? 'Tín chỉ phải từ 1 đến 10' : 'Credits must be between 1 and 10';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l.isVietnamese ? 'Ghi chú' : 'Notes',
                  hintText: l.isVietnamese ? 'Tùy chọn' : 'Optional',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  final result = FormValidator.validateOptionalLength(v ?? '', 'Note', 500);
                  return result.isFailure()
                      ? (l.isVietnamese ? 'Ghi chú tối đa 500 ký tự' : 'Notes can be up to 500 characters')
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
            widget.grade == null ? l.add : l.save,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
