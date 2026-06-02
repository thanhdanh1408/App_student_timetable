// lib/features/exam/presentation/widgets/exam_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/core/l10n/app_localizations.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/exam_entity.dart';
import '../../../subjects/domain/entities/subject_entity.dart';
import '../../../subjects/presentation/providers/subjects_provider.dart';

class ExamFormDialog extends ConsumerStatefulWidget {
  final ExamEntity? exam;
  final Function(ExamEntity) onSave;
  final List<ExamEntity> existingExams;

  const ExamFormDialog({
    super.key,
    this.exam,
    required this.onSave,
    this.existingExams = const [],
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
    final l = AppLocalizations.of(context);
    
    if (_examType != null) {
      final validValues = [l.finalExam, l.midtermExam, l.regularExam];
      if (!validValues.contains(_examType)) {
        if (_examType == 'Giữa kỳ' || _examType == 'Midterm') {
          _examType = l.midtermExam;
        } else if (_examType == 'Cuối kỳ' || _examType == 'Final') {
          _examType = l.finalExam;
        } else if (_examType == 'Thường xuyên' || _examType == 'Regular') {
          _examType = l.regularExam;
        } else {
          _examType = null;
        }
      }
    }

    final List<SubjectEntity> subjects = ref.watch(subjectsListProvider).maybeWhen(
      data: (data) => data,
      orElse: () => <SubjectEntity>[],
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
      time == null
        ? (AppLocalizations.of(context).isVietnamese ? 'Chưa chọn' : 'Not selected')
        : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime? date) =>
      date == null
        ? (AppLocalizations.of(context).isVietnamese ? 'Chưa chọn' : 'Not selected')
        : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  void dispose() {
    _examRoomController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Check for exam conflicts within 60 minutes on the same date
  String? _checkExamConflict() {
    if (_selectedDate == null || _startTime == null) return null;

    final newExamMinutes = _startTime!.hour * 60 + _startTime!.minute;

    for (final existing in widget.existingExams) {
      // Skip self when editing
      if (widget.exam != null && existing.id == widget.exam!.id) continue;
      // Only check same date
      if (existing.examDate == null) continue;
      if (existing.examDate!.year != _selectedDate!.year ||
          existing.examDate!.month != _selectedDate!.month ||
          existing.examDate!.day != _selectedDate!.day) {
        continue;
      }

      // Parse existing exam time
      if (existing.examTime == null || !existing.examTime!.contains(':')) continue;
      final existingTime = _parseTime(existing.examTime!);
      final existingMinutes = existingTime.hour * 60 + existingTime.minute;

      final gap = (newExamMinutes - existingMinutes).abs();
      if (gap < 60) {
        return '⚠️ Trùng lịch thi với "${existing.subjectName ?? "Môn khác"}" '
            'lúc ${_formatTime(existingTime)} (cách nhau chỉ $gap phút, tối thiểu 60 phút)';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final subjectsAsync = ref.watch(subjectsListProvider);
    final List<SubjectEntity> subjects = subjectsAsync.maybeWhen(
      data: (data) => data,
      orElse: () => <SubjectEntity>[],
    );

    return AlertDialog(
      title: Text(widget.exam == null ? l.addExamTitle : l.editExamTitle),
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
                  l.loadSubjectsFailed,
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
                      decoration: InputDecoration(
                        labelText: l.selectSubject,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.book),
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
                      validator: (value) => value == null ? l.selectSubjectError : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _examType,
                      decoration: InputDecoration(
                        labelText: l.selectExamTime,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      items: [
                        DropdownMenuItem(value: l.finalExam, child: Text(l.finalExam)),
                        DropdownMenuItem(value: l.midtermExam, child: Text(l.midtermExam)),
                        DropdownMenuItem(value: l.regularExam, child: Text(l.regularExam)),
                      ],
                      onChanged: (String? value) {
                        setState(() => _examType = value);
                      },
                      validator: (value) => value == null ? l.selectExamTime : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _examRoomController,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        labelText: l.examRoom,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        final result = FormValidator.validateOptionalLength(value ?? '', 'Exam room', 80);
                        return result.isFailure()
                            ? (l.isVietnamese
                                ? 'Phòng thi tối đa 80 ký tự'
                                : 'Room can be up to 80 characters')
                            : null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        labelText: l.notes,
                        hintText: l.notesHint,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.note),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        final result = FormValidator.validateOptionalLength(value ?? '', 'Notes', 1000);
                        return result.isFailure()
                            ? (l.isVietnamese
                                ? 'Ghi chú tối đa 1000 ký tự'
                                : 'Notes can be up to 1000 characters')
                            : null;
                      },
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
                        decoration: InputDecoration(
                          labelText: l.examDate,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.event),
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
                        decoration: InputDecoration(
                          labelText: l.examTime,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.schedule),
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
          child: Text(l.cancel, style: const TextStyle(color: Colors.black)),
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
                    // Check for exam conflicts (60-minute gap)
                    final conflict = _checkExamConflict();
                    if (conflict != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(conflict),
                          backgroundColor: Colors.orange,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                      return;
                    }

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
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    } catch (e) {
                      if (!context.mounted) return;
                      setState(() => _isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ ${l.errorOccurred}: ${e.toString()}'),
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
                  widget.exam == null ? l.add : l.save,
                  style: const TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }
}