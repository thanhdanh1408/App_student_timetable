// lib/features/subjects/presentation/widgets/subject_form_dialog.dart
import 'package:flutter/material.dart';
import '../../domain/entities/subject_entity.dart';
import '../../../../core/utils/validators.dart';
import '/core/l10n/app_localizations.dart';

class SubjectFormDialog extends StatefulWidget {
  final SubjectEntity? subject;
  final Function(SubjectEntity) onSave;
  final List<SubjectEntity> existingSubjects;

  const SubjectFormDialog({super.key, this.subject, required this.onSave, this.existingSubjects = const []});

  @override
  State<SubjectFormDialog> createState() => _SubjectFormDialogState();
}

class _SubjectFormDialogState extends State<SubjectFormDialog> {
  late TextEditingController _nameCtrl, _teacherCtrl;
  int _credit = 3;
  Color _selectedColor = Colors.blue;
  String? _validationError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.subject?.subjectName ?? '');
    _teacherCtrl = TextEditingController(text: widget.subject?.teacherName ?? '');
    _credit = widget.subject?.credit ?? 3;
    // Parse color from hex string if available
    if (widget.subject?.color != null) {
      try {
        _selectedColor = Color(int.parse(widget.subject!.color!.replaceFirst('#', '0xFF')));
      } catch (e) {
        _selectedColor = Colors.blue;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _teacherCtrl.dispose();
    super.dispose();
  }

  /// Validate form using FormValidator
  bool _validateForm() {
    setState(() => _validationError = null);

    // Validate subject name
    final nameResult = FormValidator.validateSubjectName(_nameCtrl.text);
    if (nameResult.isFailure()) {
      setState(() => _validationError = nameResult.failureOrNull()?.message);
      return false;
    }

    // Check duplicate subject name
    final trimmedName = _nameCtrl.text.trim().toLowerCase();
    final isDuplicate = widget.existingSubjects.any((s) =>
        s.subjectName.toLowerCase() == trimmedName &&
        s.id != widget.subject?.id);
    if (isDuplicate) {
      setState(() => _validationError = 'Tên môn học đã tồn tại!');
      return false;
    }

    // Validate teacher name (optional but validate if provided)
    if (_teacherCtrl.text.isNotEmpty) {
      final teacherResult = FormValidator.validateTeacherName(_teacherCtrl.text);
      if (teacherResult.isFailure()) {
        setState(() => _validationError = teacherResult.failureOrNull()?.message);
        return false;
      }
    }

    // Validate credit
    final creditResult = FormValidator.validateCredit(_credit);
    if (creditResult.isFailure()) {
      setState(() => _validationError = creditResult.failureOrNull()?.message);
      return false;
    }

    return true;
  }

  /// Handle save button
  void _handleSave() {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final subject = SubjectEntity(
        id: widget.subject?.id,
        subjectName: _nameCtrl.text.trim(),
        teacherName: _teacherCtrl.text.trim().isEmpty ? null : _teacherCtrl.text.trim(),
        credit: _credit,
        color: '#${_selectedColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
      );

      widget.onSave(subject);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _validationError = 'Lỗi: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(
        widget.subject == null ? (l.isVietnamese ? "Thêm môn học" : "Add subject") : (l.isVietnamese ? "Sửa môn học" : "Edit subject"),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error message display
            if (_validationError != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _validationError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            if (_validationError != null) const SizedBox(height: 12),
            // Subject name field
            TextField(
              controller: _nameCtrl,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: l.isVietnamese ? "Tên môn học *" : "Subject Name *",
                border: const OutlineInputBorder(),
                hintText: l.isVietnamese ? "Nhập tên môn học" : "Enter subject name",
                prefixIcon: const Icon(Icons.book),
              ),
            ),
            const SizedBox(height: 12),
            // Teacher name field
            TextField(
              controller: _teacherCtrl,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: l.isVietnamese ? "Giảng viên" : "Teacher",
                border: const OutlineInputBorder(),
                hintText: l.isVietnamese ? "Nhập tên giảng viên (tùy chọn)" : "Enter teacher name (optional)",
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            // Color picker
            InkWell(
              onTap: _isLoading ? null : _pickColor,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l.isVietnamese ? "Màu sắc" : "Color",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.palette),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(l.isVietnamese ? 'Nhấn để chọn' : 'Tap to select'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Credit dropdown
            InputDecorator(
              decoration: InputDecoration(
                labelText: l.isVietnamese ? "Tín chỉ" : "Credits",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.numbers),
              ),
              child: DropdownButton<int>(
                value: _credit,
                isDense: true,
                isExpanded: true,
                underline: const SizedBox(),
                items: [1, 2, 3, 4]
                    .map((c) => DropdownMenuItem<int>(
                          value: c,
                          child: Text(l.isVietnamese ? "$c tín chỉ" : "$c credits"),
                        ))
                    .toList(),
                onChanged: _isLoading ? null : (value) {
                  setState(() => _credit = value ?? 3);
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(l.cancel, style: const TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            disabledBackgroundColor: Colors.grey,
          ),
          onPressed: _isLoading ? null : _handleSave,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  widget.subject == null ? l.add : l.save,
                  style: const TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }

  /// Show color picker dialog
  Future<void> _pickColor() async {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
    ];

    final Color? picked = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).isVietnamese ? 'Chọn màu sắc' : 'Choose color'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () => Navigator.pop(context, colors[index]),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors[index],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedColor == colors[index]
                          ? Colors.black
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    if (picked != null) {
      setState(() => _selectedColor = picked);
    }
  }
}
