import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core/l10n/app_localizations.dart';

import '../../../subjects/presentation/viewmodels/subjects_viewmodel.dart';
import '../../domain/entities/note_entity.dart';

class NoteFormDialog extends StatefulWidget {
  final NoteEntity? note;
  final Future<void> Function(NoteEntity) onSave;

  const NoteFormDialog({
    super.key,
    this.note,
    required this.onSave,
  });

  @override
  State<NoteFormDialog> createState() => _NoteFormDialogState();
}

class _NoteFormDialogState extends State<NoteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  late final TextEditingController _tagsCtrl;

  String? _subjectId;
  String? _subjectName;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.note?.content ?? '');
    _tagsCtrl = TextEditingController(text: widget.note?.tags.join(', ') ?? '');
    _subjectId = widget.note?.subjectId;
    _subjectName = widget.note?.subjectName;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final tags = _tagsCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final note = NoteEntity(
      id: widget.note?.id,
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      subjectId: _subjectId,
      subjectName: _subjectName,
      tags: tags,
      createdAt: widget.note?.createdAt,
      updatedAt: DateTime.now(),
    );

    await widget.onSave(note);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final subjectsVm = context.watch<SubjectsViewModel>();
    final subjects = subjectsVm.subjects;

    return AlertDialog(
      title: Text(widget.note == null
          ? (l.isVietnamese ? 'Thêm ghi chú' : 'Add note')
          : (l.isVietnamese ? 'Sửa ghi chú' : 'Edit note')),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  decoration: InputDecoration(labelText: l.isVietnamese ? 'Tiêu đề' : 'Title'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return l.isVietnamese ? 'Vui lòng nhập tiêu đề' : 'Please enter a title';
                    }
                    if (v.trim().length > 200) {
                      return l.isVietnamese
                          ? 'Tiêu đề tối đa 200 ký tự'
                          : 'Title can be up to 200 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String?>(
                  value: _subjectId,
                  decoration: InputDecoration(labelText: l.isVietnamese ? 'Môn học (tùy chọn)' : 'Subject (optional)'),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(l.isVietnamese ? 'Không chọn môn học' : 'No subject'),
                    ),
                    ...subjects.map(
                      (s) => DropdownMenuItem<String?>(
                        value: s.id,
                        child: Text(s.subjectName),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _subjectId = value;
                      if (value == null) {
                        _subjectName = null;
                      } else {
                        final selected = subjects.firstWhere((s) => s.id == value);
                        _subjectName = selected.subjectName;
                      }
                    });
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _tagsCtrl,
                  decoration: InputDecoration(
                    labelText: l.isVietnamese ? 'Thẻ (ngăn cách bằng dấu phẩy)' : 'Tags (comma separated)',
                    hintText: 'midterm, chapter1',
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _contentCtrl,
                  decoration: InputDecoration(labelText: l.isVietnamese ? 'Nội dung' : 'Content'),
                  maxLines: 8,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return l.isVietnamese ? 'Vui lòng nhập nội dung ghi chú' : 'Please enter note content';
                    }
                    if (v.trim().length > 20000) {
                      return l.isVietnamese
                          ? 'Nội dung tối đa 20000 ký tự'
                          : 'Content can be up to 20000 characters';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _submit,
          child: Text(_saving ? l.loading : l.save),
        ),
      ],
    );
  }
}
