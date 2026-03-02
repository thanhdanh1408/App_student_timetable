import 'package:flutter/material.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/usecases/get_schedules_usecase.dart';
import '../../domain/usecases/add_schedule_usecase.dart';
import '../../domain/usecases/update_schedule_usecase.dart';
import '../../domain/usecases/delete_schedule_usecase.dart';
import '/core/services/notification_service.dart';
import '/core/providers/notification_settings_provider.dart';

class ScheduleViewModel with ChangeNotifier {
  final GetSchedulesUsecase _get;
  final AddScheduleUsecase _add;
  final UpdateScheduleUsecase _update;
  final DeleteScheduleUsecase _delete;
  final NotificationSettingsProvider? _notificationSettings;

  ScheduleViewModel({
    required GetSchedulesUsecase get,
    required AddScheduleUsecase add,
    required UpdateScheduleUsecase update,
    required DeleteScheduleUsecase delete,
    NotificationSettingsProvider? notificationSettings,
  })  : _get = get,
        _add = add,
        _update = update,
        _delete = delete,
        _notificationSettings = notificationSettings;

  List<ScheduleEntity> _schedules = [];
  bool _isLoading = false;
  String? _error;

  List<ScheduleEntity> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _schedules = await _get();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> add(ScheduleEntity s) async {
    print('📌 [ScheduleViewModel] Adding schedule: ${s.subjectName}');
    try {
      final newId = await _add(s);
      final addedSchedule = s.copyWith(id: newId);
      await load();
      print('📌 [ScheduleViewModel] Schedule added (ID: $newId), now scheduling notification...');

      await _scheduleNotificationForSchedule(addedSchedule);
      print('📌 [ScheduleViewModel] Notification scheduling completed');
    } catch (e) {
      print('❌ [ScheduleViewModel] Error adding schedule: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> update(ScheduleEntity s) async {
    try {
      await _update(s);
      await load();
      // Reschedule notification
      if (s.id != null) {
        await NotificationService().cancelNotification(s.id!);
      }
      await _scheduleNotificationForSchedule(s);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> delete(String id) async {
    try {
      await _delete(id);
      // Cancel notification for this schedule
      await NotificationService().cancelNotification(id);
      await load();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Kiểm tra xung đột lịch học (thời gian trùng)
  /// Trả về null nếu không có xung đột, hoặc tên môn học bị trùng
  String? checkScheduleConflict(ScheduleEntity newSchedule) {
    // Không kiểm tra với chính nó khi update
    final otherSchedules = _schedules.where((s) => s.id != newSchedule.id).toList();

    for (final existing in otherSchedules) {
      // Kiểm tra cùng ngày
      if (existing.dayOfWeek == newSchedule.dayOfWeek) {
        // Parse thời gian
        final existingStart = _parseTimeToMinutes(existing.startTime);
        final existingEnd = _parseTimeToMinutes(existing.endTime);
        final newStart = _parseTimeToMinutes(newSchedule.startTime);
        final newEnd = _parseTimeToMinutes(newSchedule.endTime);

        if (existingStart == null || existingEnd == null || newStart == null || newEnd == null) {
          continue; // Skip nếu không parse được
        }

        // Kiểm tra overlap: (start1 < end2) AND (start2 < end1)
        if (newStart < existingEnd && existingStart < newEnd) {
          return existing.subjectName ?? 'Một môn học khác';
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

  Future<void> _scheduleNotificationForSchedule(ScheduleEntity schedule) async {
    print('📅 [ENTER] _scheduleNotificationForSchedule for ${schedule.subjectName}, ID: ${schedule.id}');

    if (schedule.id == null) {
      print('❌ [EXIT] schedule.id is NULL! Cannot schedule notification');
      return;
    }

    if (schedule.dayOfWeek == null || schedule.startTime == null) {
      print('❌ [EXIT] schedule.dayOfWeek or schedule.startTime is NULL! Cannot schedule notification');
      return;
    }

    print('✅ schedule.id is ${schedule.id}, continuing...');

    if (_notificationSettings != null && !_notificationSettings!.enableScheduleNotifications) {
      print('⚠️ Schedule notifications are disabled in settings');
      return;
    }

    final reminderMinutes = _notificationSettings?.scheduleReminderMinutes ?? 15;

    final now = DateTime.now();
    DateTime nextOccurrence;
    try {
      nextOccurrence = _getNextOccurrence(schedule.dayOfWeek!, schedule.startTime!);
    } catch (e) {
      print('❌ Failed to parse schedule startTime (${schedule.startTime}): $e');
      return;
    }

    final notificationTime = nextOccurrence.subtract(Duration(minutes: reminderMinutes));

    print('📅 ========================================');
    print('📅 SCHEDULE NOTIFICATION SETUP');
    print('📅 Subject: ${schedule.subjectName}');
    print('📅 Day of week: ${schedule.dayOfWeek}');
    print('📅 Start time: ${schedule.startTime}');
    print('📅 Next occurrence (class time): $nextOccurrence');
    print('📅 Reminder time setting: $reminderMinutes minutes before');
    print('📅 Notification time: $notificationTime');
    print('📅 Current time: $now');
    print('📅 Minutes until notification: ${notificationTime.difference(now).inMinutes}');

    if (notificationTime.isBefore(now.add(const Duration(seconds: 30)))) {
      print('📌 Notification time very close/past, showing immediately!');
      await NotificationService().showImmediateNotification(
        id: schedule.id!,
        title: '📚 Sắp đến giờ học: ${schedule.subjectName}',
        body: 'Phòng ${schedule.location} • ${schedule.startTime}${schedule.endTime != null ? " - ${schedule.endTime}" : ""}',
        payload: 'schedule_${schedule.id}',
        type: 'schedule',
      );
    } else {
      await NotificationService().scheduleNotification(
        id: schedule.id!,
        title: '📚 Sắp đến giờ học: ${schedule.subjectName}',
        body: 'Phòng ${schedule.location} • ${schedule.startTime}${schedule.endTime != null ? " - ${schedule.endTime}" : ""}',
        scheduledTime: notificationTime,
        payload: 'schedule_${schedule.id}',
        type: 'schedule',
      );
    }

    if (notificationTime.difference(now).inDays >= 7) {
      print('✅ Notification scheduled for next week: ${notificationTime.toString()}');
    } else if (notificationTime.isAfter(now.add(const Duration(seconds: 30)))) {
      print('✅ Notification scheduled successfully: ${notificationTime.toString()}');
    } else {
      print('✅ Notification shown immediately (time very close/past)');
    }
    print('📅 ========================================');
  }

  DateTime _getNextOccurrence(int dayOfWeek, String timeStr) {
    final now = DateTime.now();
    final timeParts = timeStr.split(':');
    if (timeParts.length < 2) {
      throw FormatException('Invalid time format: $timeStr');
    }
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final targetWeekday = dayOfWeek == 8 ? 7 : dayOfWeek - 1;

    int daysToAdd = (targetWeekday - now.weekday) % 7;
    if (daysToAdd == 0) {
      final todayClassTime = DateTime(now.year, now.month, now.day, hour, minute);
      if (todayClassTime.isAfter(now)) {
        return todayClassTime;
      } else {
        daysToAdd = 7;
      }
    }

    return DateTime(
      now.year,
      now.month,
      now.day + daysToAdd,
      hour,
      minute,
    );
  }
}

// Backward-compatible alias (old naming used across the UI).
