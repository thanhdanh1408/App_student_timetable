// lib/features/schedule/presentation/widgets/schedule_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/validators.dart';
import '../../../subjects/presentation/providers/subjects_provider.dart';
import '../../../subjects/domain/entities/subject_entity.dart';
import '../../domain/entities/schedule_entity.dart';

class ScheduleFormDialog extends ConsumerStatefulWidget {
  final ScheduleEntity? schedule;
  final Function(ScheduleEntity) onSave;

  const ScheduleFormDialog({super.key, this.schedule, required this.onSave});

  @override
  ConsumerState<ScheduleFormDialog> createState() => _ScheduleFormDialogState();
}

class _ScheduleFormDialogState extends ConsumerState<ScheduleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  SubjectEntity? _selectedSubject;
  late TextEditingController _locationCtrl;
  late TextEditingController _notesCtrl;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int? _dayOfWeek;
  String? _validationError;
  bool _isLoading = false;

  bool _didInitFromData = false;

  @override
  void initState() {
    super.initState();
    _locationCtrl = TextEditingController();
    _notesCtrl = TextEditingController();

    // Provide safe defaults; we'll sync actual values in didChangeDependencies.
    _startTime = const TimeOfDay(hour: 7, minute: 30);
    _endTime = const TimeOfDay(hour: 9, minute: 0);
    _dayOfWeek = 2;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitFromData) return;

    final subjects = ref.watch(subjectsListProvider).maybeWhen(
      data: (data) => data,
      orElse: () => [],
    );

    if (widget.schedule != null) {
      final schedule = widget.schedule!;

      // Subject
      if (subjects.isNotEmpty) {
        _selectedSubject = subjects.firstWhere(
          (s) => s.id == schedule.subjectId,
          orElse: () => subjects.first,
        );
      } else {
        _selectedSubject = null;
      }

      // Location & day
      _locationCtrl.text = schedule.location ?? '';
      _notesCtrl.text = schedule.notes ?? '';
      _dayOfWeek = schedule.dayOfWeek ?? _dayOfWeek;

      // Times
      _startTime = _parseTime(schedule.startTime);
      _endTime = _parseTime(schedule.endTime);

      // If subjects aren't loaded yet, wait for next didChangeDependencies.
      if (subjects.isEmpty && schedule.subjectId != null) {
        return;
      }
    } else {
      // New schedule: choose defaults from first subject if available
      if (subjects.isNotEmpty) {
        _selectedSubject = subjects.first;
      }
    }

    _didInitFromData = true;
  }

  TimeOfDay _parseTime(String? time) {
    if (time == null) return const TimeOfDay(hour: 7, minute: 0);
    try {
      final parts = time.split(':');
      if (parts.length < 2) return const TimeOfDay(hour: 7, minute: 0);
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return const TimeOfDay(hour: 7, minute: 0);
    }
  }

  String _formatTime(TimeOfDay? time) => time == null ? "Chưa chọn" : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? (_startTime ?? const TimeOfDay(hour: 7, minute: 0)) : (_endTime ?? const TimeOfDay(hour: 9, minute: 0)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _validateForm() {
    // Validate location
    final locationResult = FormValidator.validateLocation(_locationCtrl.text);
    if (locationResult.isFailure()) {
      setState(() => _validationError = locationResult.failureOrNull()?.message);
      return;
    }

    // Validate time format
    if (_startTime == null || _endTime == null) {
      setState(() => _validationError = "Vui lòng chọn giờ bắt đầu và kết thúc");
      return;
    }

    // Validate time range (start < end)
    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
    if (endMinutes <= startMinutes) {
      setState(() => _validationError = "Giờ kết thúc phải sau giờ bắt đầu");
      return;
    }

    // Validate max duration (6 hours)
    final durationMinutes = endMinutes - startMinutes;
    if (durationMinutes > 360) {
      setState(() => _validationError = "Thời lượng buổi học không được vượt quá 6 giờ");
      return;
    }

    setState(() => _validationError = null);
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectsListProvider);
    final subjects = subjectsAsync.maybeWhen(
      data: (data) => data,
      orElse: () => [],
    );

    return AlertDialog(
      title: Text(widget.schedule == null ? "Thêm buổi học" : "Chỉnh sửa buổi học"),
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
                    // Validation error container
                    if (_validationError != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          border: Border.all(color: Colors.red[400]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red[600], size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _validationError!,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Subject dropdown
                    DropdownButtonFormField<SubjectEntity>(
                      value: _selectedSubject,
                      decoration: const InputDecoration(
                        labelText: "Chọn môn học*",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.book),
                      ),
                      items: subjects
                          .map<DropdownMenuItem<SubjectEntity>>((s) =>
                              DropdownMenuItem(value: s, child: Text(s.subjectName)))
                          .toList(),
                      onChanged: (s) {
                        setState(() {
                          _selectedSubject = s;
                          _validationError = null;
                        });
                      },
                      validator: (v) => v == null ? "Chọn môn học" : null,
                    ),
                    const SizedBox(height: 16),
                    // Day of week dropdown
                    DropdownButtonFormField<int>(
                      value: _dayOfWeek,
                      decoration: const InputDecoration(
                        labelText: "Thứ*",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      items: [
                        DropdownMenuItem(value: 2, child: const Text("Thứ 2")),
                        DropdownMenuItem(value: 3, child: const Text("Thứ 3")),
                        DropdownMenuItem(value: 4, child: const Text("Thứ 4")),
                        DropdownMenuItem(value: 5, child: const Text("Thứ 5")),
                        DropdownMenuItem(value: 6, child: const Text("Thứ 6")),
                        DropdownMenuItem(value: 7, child: const Text("Thứ 7")),
                        DropdownMenuItem(value: 8, child: const Text("Chủ nhật")),
                      ],
                      onChanged: (v) {
                        setState(() {
                          _dayOfWeek = v;
                          _validationError = null;
                        });
                      },
                      validator: (v) => v == null ? "Chọn thứ" : null,
                    ),
                    const SizedBox(height: 16),
                    // Location field
                    TextFormField(
                      controller: _locationCtrl,
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        labelText: "Địa điểm",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      onChanged: (_) {
                        if (_validationError != null) {
                          _validateForm();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Notes field
                    TextFormField(
                      controller: _notesCtrl,
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        labelText: "Ghi chú",
                        hintText: "Nhập ghi chú (tùy chọn)",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    // Start time picker
                    GestureDetector(
                      onTap: _isLoading ? null : () => _pickTime(true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: "Giờ bắt đầu*",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.schedule),
                        ),
                        child: Text(_formatTime(_startTime)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // End time picker
                    GestureDetector(
                      onTap: _isLoading ? null : () => _pickTime(false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: "Giờ kết thúc*",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.schedule),
                        ),
                        child: Text(_formatTime(_endTime)),
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
                  _validateForm();
                  if (_validationError != null) return;

                  if (!_formKey.currentState!.validate()) return;
                  if (_selectedSubject == null) {
                    setState(() => _validationError = "Chọn môn học");
                    return;
                  }

                  setState(() => _isLoading = true);

                  try {
                    final schedule = ScheduleEntity(
                      id: widget.schedule?.id,
                      subjectId: _selectedSubject?.id,
                      subjectName: _selectedSubject?.subjectName,
                      teacherName: _selectedSubject?.teacherName,
                      dayOfWeek: _dayOfWeek,
                      startTime: _formatTime(_startTime),
                      endTime: _formatTime(_endTime),
                      location: _locationCtrl.text.trim(),
                      notes: _notesCtrl.text.trim().isEmpty
                          ? null
                          : _notesCtrl.text.trim(),
                      color: _selectedSubject?.color,
                      isEnabled: true,
                    );

                    await widget.onSave(schedule);
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
                  widget.schedule == null ? "Thêm" : "Lưu",
                  style: const TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }
}