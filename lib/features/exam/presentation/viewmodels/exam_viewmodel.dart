import 'package:flutter/material.dart';
import '../../domain/entities/exam_entity.dart';
import '../../domain/usecases/get_exams_usecase.dart';
import '../../domain/usecases/add_exam_usecase.dart';
import '../../domain/usecases/update_exam_usecase.dart';
import '../../domain/usecases/delete_exam_usecase.dart';
import '/core/services/notification_service.dart';
import '/core/providers/notification_settings_provider.dart';

class ExamViewModel with ChangeNotifier {
  final GetExamsUsecase _get;
  final AddExamUsecase _add;
  final UpdateExamUsecase _update;
  final DeleteExamUsecase _delete;
  final NotificationSettingsProvider? _notificationSettings;

  ExamViewModel({
    required GetExamsUsecase get,
    required AddExamUsecase add,
    required UpdateExamUsecase update,
    required DeleteExamUsecase delete,
    NotificationSettingsProvider? notificationSettings,
  })  : _get = get,
        _add = add,
        _update = update,
        _delete = delete,
        _notificationSettings = notificationSettings;

  List<ExamEntity> _exams = [];
  bool _isLoading = false;
  String? _error;

  List<ExamEntity> get exams => _exams;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _exams = await _get();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> add(ExamEntity e) async {
    try {
      final newId = await _add(e);
      final addedExam = e.copyWith(id: newId);
      await load();
      await _scheduleNotificationForExam(addedExam);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> update(ExamEntity e) async {
    try {
      await _update(e);
      await load();
      if (e.id != null) {
        await NotificationService().cancelNotification(e.id!);
      }
      await _scheduleNotificationForExam(e);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> delete(String id) async {
    try {
      await _delete(id);
      await NotificationService().cancelNotification(id);
      await load();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Kiểm tra xung đột lịch thi (cùng ngày và giờ)
  /// Trả về null nếu không có xung đột, hoặc tên môn thi bị trùng
  String? checkExamConflict(ExamEntity newExam) {
    if (newExam.examDate == null || newExam.examTime == null) {
      return null; // Không thể kiểm tra nếu thiếu thông tin
    }

    // Không kiểm tra với chính nó khi update
    final otherExams = _exams.where((e) => e.id != newExam.id).toList();

    for (final existing in otherExams) {
      if (existing.examDate == null || existing.examTime == null) {
        continue;
      }

      // Kiểm tra cùng ngày
      if (existing.examDate!.year == newExam.examDate!.year &&
          existing.examDate!.month == newExam.examDate!.month &&
          existing.examDate!.day == newExam.examDate!.day) {
        
        // Kiểm tra cùng giờ (hoặc gần nhau trong vòng 2 giờ)
        final existingMinutes = _parseTimeToMinutes(existing.examTime);
        final newMinutes = _parseTimeToMinutes(newExam.examTime);

        if (existingMinutes != null && newMinutes != null) {
          // Cho phép 2 kỳ thi cách nhau ít nhất 2 giờ (120 phút)
          final timeDiff = (existingMinutes - newMinutes).abs();
          if (timeDiff < 120) {
            return existing.subjectName ?? 'Một môn thi khác';
          }
        }
      }
    }
    return null; // Không có xung đột
  }

  /// Parse time string "HH:mm" thành tổng số phút
  int? _parseTimeToMinutes(String? time) {
    if (time == null || time.isEmpty) return null;
    try {
      final parts = time.split(':');
      if (parts.length < 2) return null;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return hour * 60 + minute;
    } catch (e) {
      return null;
    }
  }

  Future<void> _scheduleNotificationForExam(ExamEntity exam) async {
    print('📝 [ENTER] _scheduleNotificationForExam for ${exam.subjectName}, ID: ${exam.id}');

    if (exam.id == null) {
      print('❌ [EXIT] exam.id is NULL! Cannot schedule notification');
      return;
    }

    if (exam.examDate == null || exam.examTime == null) {
      print('❌ [EXIT] exam.examDate or exam.examTime is NULL! Cannot schedule notification');
      return;
    }

    print('✅ exam.id is ${exam.id}, continuing...');

    if (_notificationSettings != null && !_notificationSettings!.enableExamNotifications) {
      print('⚠️ Exam notifications are disabled in settings');
      return;
    }

    final reminderMinutes = _notificationSettings?.examReminderMinutes ?? 60;

    final timeParts = exam.examTime!.split(':');
    if (timeParts.length < 2) {
      print('❌ [EXIT] Invalid examTime format: ${exam.examTime}');
      return;
    }
    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    if (hour == null || minute == null) {
      print('❌ [EXIT] Invalid examTime values: ${exam.examTime}');
      return;
    }

    final examDateTime = DateTime(
      exam.examDate!.year,
      exam.examDate!.month,
      exam.examDate!.day,
      hour,
      minute,
    );

    final notificationTime = examDateTime.subtract(Duration(minutes: reminderMinutes));

    print('📝 ========================================');
    print('📝 EXAM NOTIFICATION SETUP');
    print('📝 Subject: ${exam.subjectName}');
    print('📝 Exam date/time: $examDateTime');
    print('📝 Reminder time setting: $reminderMinutes minutes before');
    print('📝 Notification time: $notificationTime');
    print('📝 Current time: ${DateTime.now()}');
    print('📝 Minutes until notification: ${notificationTime.difference(DateTime.now()).inMinutes}');

    final now = DateTime.now();
    if (notificationTime.isBefore(now.add(const Duration(seconds: 30)))) {
      print('📌 Notification time very close/past, showing immediately!');
      await NotificationService().showImmediateNotification(
        id: exam.id!,
        title: '📝 Sắp đến giờ thi: ${exam.subjectName}',
        body: 'Giờ thi: ${exam.examTime}${exam.examRoom != null && exam.examRoom!.isNotEmpty ? " • Phòng: ${exam.examRoom}" : ""}',
        payload: 'exam_${exam.id}',
        type: 'exam',
      );
      print('✅ Exam notification shown immediately');
    } else {
      await NotificationService().scheduleNotification(
        id: exam.id!,
        title: '📝 Sắp đến giờ thi: ${exam.subjectName}',
        body: 'Giờ thi: ${exam.examTime}${exam.examRoom != null && exam.examRoom!.isNotEmpty ? " • Phòng: ${exam.examRoom}" : ""}',
        scheduledTime: notificationTime,
        payload: 'exam_${exam.id}',
        type: 'exam',
      );
      print('✅ Exam notification scheduled successfully');
    }
  }
}

// Backward-compatible alias (old naming used across the UI).
