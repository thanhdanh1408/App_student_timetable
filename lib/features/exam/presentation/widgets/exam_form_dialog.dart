// lib/features/exam/presentation/widgets/exam_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/exam_entity.dart';
import '../../../subjects/domain/entities/subject_entity.dart';
import '../../../subjects/presentation/providers/subjects_provider.dart';

class ExamFormDialog extends ConsumerStatefulWidget {
  final ExamEntity? exam;
  final Function(ExamEntity) onSave;

  const ExamFormDialog({
    super.key,
    this.exam,
    required this.onSave,
  });

  @override
  ConsumerState<ExamFormDialog> createState() => _ExamFormDialogState();
}

class _ExamFormDialogState extends ConsumerState<ExamFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _examRoomController = TextEditingController();
  final _notesController = TextEditingController();
  late SubjectEntity? _selectedSubject;
  String? _examType;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.exam?.examDate;
    _examType = widget.exam?.examName;
    _examRoomController.text = widget.exam?.examRoom ?? '';
    _notesController.text = widget.exam?.notes ?? '';
    _startTime = widget.exam != null && widget.exam!.examTime != null 
        ? _parseTime(widget.exam!.examTime!) 
        : null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final subjects = ref.watch(subjectsListProvider).maybeWhen(
      data: (data) => data,
      orElse: () => [],
    );

    if (widget.exam != null && subjects.isNotEmpty) {
      _selectedSubject = subjects.firstWhere(
        (s) => s.id == widget.exam!.subjectId,
        orElse: () => subjects.first,
      );
    } else {
      _selectedSubject = subjects.isNotEmpty ? subjects.first : null;
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
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectsListProvider);
    final subjects = subjectsAsync.maybeWhen(
      data: (data) => data,
      orElse: () => [],
    );

    return AlertDialog(
      title: Text(widget.exam == null ? "Thêm lịch thi" : "Sửa lịch thi"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (subjectsAsync.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (subjectsAsync.hasError)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Lỗi tải danh sách môn học",
                  style: TextStyle(color: Colors.red[600]),
                ),
              )
            else
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<SubjectEntity>(
                      value: _selectedSubject,
                      decoration: const InputDecoration(
                        labelText: "Môn thi*",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.book),
                      ),
                      items: subjects
                          .map<DropdownMenuItem<SubjectEntity>>((subject) =>
                              DropdownMenuItem(
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
                        prefixIcon: Icon(Icons.calendar_today),
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
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        labelText: "Phòng thi",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        labelText: "Ghi chú",
                        hintText: "Nhập ghi chú (tùy chọn)",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _isLoading ? null : () async {
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
                          prefixIcon: Icon(Icons.event),
                        ),
                        child: Text(_formatDate(_selectedDate)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _isLoading ? null : () async {
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
                          prefixIcon: Icon(Icons.schedule),
                        ),
                        child: Text(_formatTime(_startTime)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text("Hủy", style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            disabledBackgroundColor: Colors.grey,
          ),
          onPressed: _isLoading
              ? null
              : () async {
                  if (_formKey.currentState!.validate() && _selectedDate != null && _startTime != null) {
                    setState(() => _isLoading = true);
                    try {
                      final exam = ExamEntity(
                        id: widget.exam?.id,
                        subjectId: _selectedSubject?.id,
                        subjectName: _selectedSubject?.subjectName,
                        teacherName: _selectedSubject?.teacherName,
                        examDate: _selectedDate,
                        examTime: _formatTime(_startTime),
                        examName: _examType,
                        examRoom: _examRoomController.text.trim().isEmpty
                            ? null
                            : _examRoomController.text.trim(),
                        notes: _notesController.text.trim().isEmpty
                            ? null
                            : _notesController.text.trim(),
                        color: _selectedSubject?.color,
                        isCompleted: false,
                      );

                      await widget.onSave(exam);
                      if (!mounted) return;
                      Navigator.pop(context);
                    } catch (e) {
                      setState(() => _isLoading = false);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("❌ Lỗi: ${e.toString()}"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  widget.exam == null ? "Thêm" : "Lưu",
                  style: const TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }
}