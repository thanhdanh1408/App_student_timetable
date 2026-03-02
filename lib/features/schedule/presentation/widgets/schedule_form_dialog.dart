// lib/features/schedule/presentation/widgets/schedule_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../subjects/presentation/viewmodels/subjects_viewmodel.dart';
import '../../../subjects/domain/entities/subject_entity.dart';
import '../../domain/entities/schedule_entity.dart';
import '../viewmodels/schedule_viewmodel.dart';

class ScheduleFormDialog extends StatefulWidget {
  final ScheduleEntity? schedule;
  final Function(ScheduleEntity) onSave;

  const ScheduleFormDialog({super.key, this.schedule, required this.onSave});

  @override
  State<ScheduleFormDialog> createState() => _ScheduleFormDialogState();
}

class _ScheduleFormDialogState extends State<ScheduleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  SubjectEntity? _selectedSubject;
  late TextEditingController _locationCtrl;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int? _dayOfWeek;

  bool _didInitFromData = false;

  @override
  void initState() {
    super.initState();
    _locationCtrl = TextEditingController();

    // Provide safe defaults; we'll sync actual values in didChangeDependencies.
    _startTime = const TimeOfDay(hour: 7, minute: 30);
    _endTime = const TimeOfDay(hour: 9, minute: 0);
    _dayOfWeek = 2;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitFromData) return;

    final subjects = context.read<SubjectsViewModel>().subjects;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjects = context.watch<SubjectsViewModel>().subjects;

    return AlertDialog(
      title: Text(widget.schedule == null ? "Thêm buổi học" : "Chỉnh sửa buổi học"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<SubjectEntity>(
                value: _selectedSubject,
                decoration: const InputDecoration(labelText: "Chọn môn học*", border: OutlineInputBorder()),
                items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s.subjectName))).toList(),
                onChanged: (s) {
                  setState(() {
                    _selectedSubject = s;
                  });
                },
                validator: (v) => v == null ? "Chọn môn học" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _dayOfWeek,
                decoration: const InputDecoration(labelText: "Thứ*", border: OutlineInputBorder()),
                items: [
                  DropdownMenuItem(value: 2, child: const Text("Thứ 2")),
                  DropdownMenuItem(value: 3, child: const Text("Thứ 3")),
                  DropdownMenuItem(value: 4, child: const Text("Thứ 4")),
                  DropdownMenuItem(value: 5, child: const Text("Thứ 5")),
                  DropdownMenuItem(value: 6, child: const Text("Thứ 6")),
                  DropdownMenuItem(value: 7, child: const Text("Thứ 7")),
                  DropdownMenuItem(value: 8, child: const Text("Chủ nhật")),
                ],
                onChanged: (v) => setState(() => _dayOfWeek = v),
                validator: (v) => v == null ? "Chọn thứ" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(labelText: "Địa điểm", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _pickTime(true),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: "Giờ bắt đầu*", border: OutlineInputBorder()),
                  child: Text(_formatTime(_startTime)),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _pickTime(false),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: "Giờ kết thúc*", border: OutlineInputBorder()),
                  child: Text(_formatTime(_endTime)),
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
            if (_formKey.currentState!.validate()) {
              if (_startTime == null || _endTime == null) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng chọn giờ bắt đầu/kết thúc'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return;
              }

              final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
              final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
              if (endMinutes <= startMinutes) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Giờ kết thúc phải sau giờ bắt đầu'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return;
              }

              // Validation 4: Kiểm tra thời lượng buổi học (tối đa 6 giờ = 360 phút)
              final durationMinutes = endMinutes - startMinutes;
              if (durationMinutes > 360) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thời lượng buổi học không được vượt quá 6 giờ'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return;
              }

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
                  color: _selectedSubject?.color,
                  isEnabled: true,
                );

                // Validation 1: Kiểm tra xung đột lịch học
                final viewModel = context.read<ScheduleViewModel>();
                final conflictSubject = viewModel.checkScheduleConflict(schedule);
                if (conflictSubject != null) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lịch học bị trùng với môn "$conflictSubject"'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                await widget.onSave(schedule);
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
            widget.schedule == null ? "Thêm" : "Lưu",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}