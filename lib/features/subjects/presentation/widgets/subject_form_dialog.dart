// lib/features/subjects/presentation/widgets/subject_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/subject_entity.dart';
import '../viewmodels/subjects_viewmodel.dart';

class SubjectFormDialog extends StatefulWidget {
  final SubjectEntity? subject;
  final Function(SubjectEntity) onSave;

  const SubjectFormDialog({super.key, this.subject, required this.onSave});

  @override
  State<SubjectFormDialog> createState() => _SubjectFormDialogState();
}

class _SubjectFormDialogState extends State<SubjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl, _teacherCtrl;
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
    return AlertDialog(
      title: Text(
        widget.subject == null ? "Thêm môn học" : "Sửa môn học",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Tên môn học*",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v?.isEmpty ?? true) ? "Vui lòng nhập tên môn học" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _teacherCtrl,
                decoration: const InputDecoration(
                  labelText: "Giảng viên",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
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
                      title: const Text('Chọn màu sắc'),
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
                  decoration: const InputDecoration(
                    labelText: "Màu sắc",
                    border: OutlineInputBorder(),
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
                      const Text('Nhấn để chọn màu'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _credit,
                decoration: const InputDecoration(
                  labelText: "Tín chỉ",
                  border: OutlineInputBorder(),
                ),
                items: [1, 2, 3, 4, 5]
                    .map((c) => DropdownMenuItem<int>(
                          value: c,
                          child: Text("$c tín chỉ"),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _credit = value ?? 3;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Hủy", style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
          ),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              try {
                // Validation 2: Kiểm tra tên môn học trùng
                final viewModel = context.read<SubjectsViewModel>();
                final isDuplicate = viewModel.checkDuplicateSubjectName(
                  _nameCtrl.text.trim(),
                  excludeId: widget.subject?.id,
                );
                if (isDuplicate) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tên môn học đã tồn tại, vui lòng chọn tên khác'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final subject = SubjectEntity(
                  id: widget.subject?.id,
                  subjectName: _nameCtrl.text.trim(),
                  teacherName: _teacherCtrl.text.trim(),
                  color: '#${_selectedColor.value.toRadixString(16).substring(2)}',
                  credit: _credit,
                );
                await widget.onSave(subject);
                if (!context.mounted) return;
                Navigator.pop(context);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Lỗi: ${e.toString()}"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: Text(
            widget.subject == null ? "Thêm" : "Lưu",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
