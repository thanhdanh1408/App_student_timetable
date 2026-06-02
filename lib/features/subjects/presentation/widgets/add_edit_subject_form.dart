// lib/features/subjects/presentation/widgets/add_edit_subject_form.dart
import 'package:flutter/material.dart';
import '../../domain/entities/subject_entity.dart';
import '/core/l10n/app_localizations.dart';

class AddEditSubjectForm extends StatefulWidget {
  final SubjectEntity? subject;
  final Function(SubjectEntity) onSave;

  const AddEditSubjectForm({super.key, this.subject, required this.onSave});

  @override
  State<AddEditSubjectForm> createState() => _AddEditSubjectFormState();
}

class _AddEditSubjectFormState extends State<AddEditSubjectForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _teacherCtrl;
  int _credit = 3;
  Color _selectedColor = Colors.blue;

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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(widget.subject == null ? Icons.add_circle_outline : Icons.edit, color: Colors.indigo),
          const SizedBox(width: 12),
          Text(
            widget.subject == null ? (l.isVietnamese ? "Thêm môn học mới" : "Add new subject") : (l.isVietnamese ? "Chỉnh sửa môn học" : "Edit subject"),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tên môn học
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: l.isVietnamese ? "Tên môn học" : "Subject name",
                    prefixIcon: const Icon(Icons.book),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v!.isEmpty ? (l.isVietnamese ? "Vui lòng nhập tên môn" : "Please enter subject name") : null,
                ),
                const SizedBox(height: 16),

                // Giảng viên
                TextFormField(
                  controller: _teacherCtrl,
                  decoration: InputDecoration(
                    labelText: l.isVietnamese ? "Giảng viên" : "Teacher",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Chọn màu sắc
                InkWell(
                  onTap: () async {
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
                        title: Text(l.isVietnamese ? 'Chọn màu sắc' : 'Choose color'),
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
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l.isVietnamese ? "Màu sắc" : "Color",
                      prefixIcon: const Icon(Icons.palette),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                        Text(l.isVietnamese ? 'Nhấn để chọn màu' : 'Tap to select color'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Số tín chỉ
                DropdownButtonFormField<int>(
                  value: _credit,
                  decoration: InputDecoration(
                    labelText: l.isVietnamese ? "Số tín chỉ" : "Credits",
                    prefixIcon: const Icon(Icons.credit_card),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: [1, 2, 3, 4, 5].map((c) => DropdownMenuItem(value: c, child: Text(l.isVietnamese ? "$c tín chỉ" : "$c credits"))).toList(),
                  onChanged: (v) => setState(() => _credit = v!),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel, style: const TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final subject = SubjectEntity(
                id: widget.subject?.id,
                subjectName: _nameCtrl.text.trim(),
                teacherName: _teacherCtrl.text.trim(),
                color: '#${_selectedColor.value.toRadixString(16).substring(2)}',
                credit: _credit,
              );
              widget.onSave(subject);
              Navigator.pop(context);
            }
          },
          child: Text(widget.subject == null ? l.add : l.save),
        ),
      ],
    );
  }
}