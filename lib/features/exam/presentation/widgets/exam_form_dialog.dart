// lib/features/exam/presentation/widgets/exam_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/exam_entity.dart';
import '../../../subjects/domain/entities/subject_entity.dart';
import '../viewmodels/exam_viewmodel.dart';

class ExamFormDialog extends StatefulWidget {
  final ExamEntity? exam;
  final List<SubjectEntity> subjects;
  final Function(ExamEntity) onSave;

  const ExamFormDialog({
    super.key,
    this.exam,
    required this.subjects,
    required this.onSave,
  });

  @override
  State<ExamFormDialog> createState() => _ExamFormDialogState();
}

class _ExamFormDialogState extends State<ExamFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _examRoomController = TextEditingController();
  late SubjectEntity? _selectedSubject;
  String? _examType;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.exam?.examDate;
    _examType = widget.exam?.examName;
    _examRoomController.text = widget.exam?.examRoom ?? '';
    _startTime = widget.exam != null && widget.exam!.examTime != null 
        ? _parseTime(widget.exam!.examTime!) 
        : null;

    if (widget.exam != null && widget.subjects.isNotEmpty) {
      _selectedSubject = widget.subjects.firstWhere(
        (s) => s.id == widget.exam!.subjectId,
        orElse: () => widget.subjects.first,
      );
    } else {
      _selectedSubject = widget.subjects.isNotEmpty ? widget.subjects.first : null;
    }
  }

  TimeOfDay _parseTime(String time) {
    try {
      final parts = time.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return const TimeOfDay(hour: 7, minute: 0);
    }
  }

  String _formatTime(TimeOfDay? time) =>
      time == null ? "Chưa chọn" : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime? date) =>
      date == null ? "Chưa chọn" : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  void dispose() {
    _examRoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.exam == null ? "Thêm lịch thi" : "Sửa lịch thi"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<SubjectEntity>(
                value: _selectedSubject,
                decoration: const InputDecoration(
                  labelText: "Môn thi*",
                  border: OutlineInputBorder(),
                ),
                items: widget.subjects
                    .map((subject) => DropdownMenuItem(
                          value: subject,
                          child: Text(subject.subjectName),
                        ))
                    .toList(),
                onChanged: (SubjectEntity? value) {
                  setState(() => _selectedSubject = value);
                },
                validator: (value) => value == null ? "Vui lòng chọn môn thi" : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _examType,
                decoration: const InputDecoration(
                  labelText: "Tên kỳ thi*",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "Cuối kỳ", child: Text("Cuối kỳ")),
                  DropdownMenuItem(value: "Giữa kỳ", child: Text("Giữa kỳ")),
                  DropdownMenuItem(value: "Thường xuyên", child: Text("Thường xuyên")),
                ],
                onChanged: (String? value) {
                  setState(() => _examType = value);
                },
                validator: (value) => value == null ? "Vui lòng chọn kỳ thi" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _examRoomController,
                decoration: const InputDecoration(
                  labelText: "Phòng thi",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Ngày thi*",
                    border: OutlineInputBorder(),
                  ),
                  child: Text(_formatDate(_selectedDate)),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: _startTime ?? const TimeOfDay(hour: 7, minute: 0),
                  );
                  if (t != null) {
                    setState(() => _startTime = t);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Giờ bắt đầu*",
                    border: OutlineInputBorder(),
                  ),
                  child: Text(_formatTime(_startTime)),
                ),
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
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
          onPressed: () async {
            if (_formKey.currentState!.validate() && _selectedDate != null && _startTime != null) {
              try {
                final exam = ExamEntity(
                  id: widget.exam?.id,
                  subjectId: _selectedSubject?.id,
                  subjectName: _selectedSubject?.subjectName,
                  teacherName: _selectedSubject?.teacherName,
                  examDate: _selectedDate,
                  examTime: _formatTime(_startTime),
                  examName: _examType,
                  examRoom: _examRoomController.text.trim().isEmpty ? null : _examRoomController.text.trim(),
                  color: _selectedSubject?.color,
                  isCompleted: false,
                );

                // Validation 3: Kiểm tra xung đột lịch thi
                final viewModel = context.read<ExamViewModel>();
                final conflictSubject = viewModel.checkExamConflict(exam);
                if (conflictSubject != null) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lịch thi bị trùng với môn "$conflictSubject" (các kỳ thi phải cách nhau ít nhất 2 giờ)'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                await widget.onSave(exam);
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
            widget.exam == null ? "Thêm" : "Lưu",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}