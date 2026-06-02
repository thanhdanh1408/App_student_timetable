// lib/features/schedule/presentation/providers/schedule_controller.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/core/services/notification_service.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/usecases/add_schedule_usecase.dart';
import '../../domain/usecases/delete_schedule_usecase.dart';
import '../../domain/usecases/update_schedule_usecase.dart';
import 'schedule_provider.dart';

/// StateNotifier for managing schedule mutations (add/update/delete)
class ScheduleController extends StateNotifier<AsyncValue<List>> {
  final AddScheduleUsecase _addUsecase;
  final UpdateScheduleUsecase _updateUsecase;
  final DeleteScheduleUsecase _deleteUsecase;
  final Ref _ref;

  ScheduleController({
    required AddScheduleUsecase addUsecase,
    required UpdateScheduleUsecase updateUsecase,
    required DeleteScheduleUsecase deleteUsecase,
    required Ref ref,
  })  : _addUsecase = addUsecase,
        _updateUsecase = updateUsecase,
        _deleteUsecase = deleteUsecase,
        _ref = ref,
        super(const AsyncValue.loading());

  /// Add a new schedule
  Future<void> addSchedule(ScheduleEntity schedule) async {
    state = const AsyncValue.loading();
    try {
      final newId = await _addUsecase.call(schedule);
      final addedSchedule = schedule.copyWith(id: newId);
      // Schedule notification for the new schedule
      await _scheduleNotificationForSchedule(addedSchedule);
      // Invalidate the schedules list provider to trigger refresh
      _ref.invalidate(schedulesListProvider);
      state = const AsyncValue.data([]);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Update an existing schedule
  Future<void> updateSchedule(ScheduleEntity schedule) async {
    state = const AsyncValue.loading();
    try {
      await _updateUsecase.call(schedule);
      // Cancel old notifications and reschedule
      if (schedule.id != null) {
        await NotificationService().cancelNotification(schedule.id!);
        await NotificationService().cancelNotification('${schedule.id!}_weekly');
      }
      await _scheduleNotificationForSchedule(schedule);
      // Invalidate the schedules list provider to trigger refresh
      _ref.invalidate(schedulesListProvider);
      state = const AsyncValue.data([]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Delete a schedule
  Future<void> deleteSchedule(String scheduleId) async {
    state = const AsyncValue.loading();
    try {
      await _deleteUsecase.call(scheduleId);
      // Cancel both primary and weekly notifications
      await NotificationService().cancelNotification(scheduleId);
      await NotificationService().cancelNotification('${scheduleId}_weekly');
      // Invalidate the schedules list provider to trigger refresh
      _ref.invalidate(schedulesListProvider);
      state = const AsyncValue.data([]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Schedule notification for a class schedule.
  /// Uses default reminder of 15 minutes before class.
  Future<void> _scheduleNotificationForSchedule(ScheduleEntity schedule) async {
    debugPrint('📅 [ScheduleController] Scheduling notification for ${schedule.subjectName}, ID: ${schedule.id}');

    if (schedule.id == null || schedule.dayOfWeek == null || schedule.startTime == null) {
      debugPrint('❌ Missing required fields for notification');
      return;
    }

    // Default reminder: 15 minutes before class
    const reminderMinutes = 15;

    final now = DateTime.now();
    DateTime nextOccurrence;
    try {
      nextOccurrence = _getNextOccurrence(schedule.dayOfWeek!, schedule.startTime!);
    } catch (e) {
      debugPrint('❌ Failed to parse startTime (${schedule.startTime}): $e');
      return;
    }

    final notificationTime = nextOccurrence.subtract(const Duration(minutes: reminderMinutes));

    debugPrint('📅 Subject: ${schedule.subjectName}');
    debugPrint('📅 Next occurrence: $nextOccurrence');
    debugPrint('📅 Notification time: $notificationTime');
    debugPrint('📅 Current time: $now');

    // Build notification body
    String body = 'Phòng ${schedule.location} • ${schedule.startTime}${schedule.endTime != null ? " - ${schedule.endTime}" : ""}';
    if (schedule.notes != null && schedule.notes!.isNotEmpty) {
      body += '\nGhi chú: ${schedule.notes}';
    }

    if (notificationTime.isBefore(now.add(const Duration(seconds: 30)))) {
      debugPrint('📌 Notification time close/past, showing immediately + scheduling weekly');
      
      await NotificationService().showImmediateNotification(
        id: schedule.id!,
        title: '📚 Sắp đến giờ học: ${schedule.subjectName}',
        body: body,
        payload: 'schedule_${schedule.id}',
        type: 'schedule',
      );

      // Also schedule weekly recurring for next week
      final nextWeekTime = notificationTime.add(const Duration(days: 7));
      await NotificationService().scheduleWeeklyNotification(
        id: '${schedule.id!}_weekly',
        title: '📚 Sắp đến giờ học: ${schedule.subjectName}',
        body: body,
        scheduledTime: nextWeekTime,
        payload: 'schedule_${schedule.id}',
        type: 'schedule',
      );
    } else {
      // Schedule weekly recurring notification
      await NotificationService().scheduleWeeklyNotification(
        id: schedule.id!,
        title: '📚 Sắp đến giờ học: ${schedule.subjectName}',
        body: body,
        scheduledTime: notificationTime,
        payload: 'schedule_${schedule.id}',
        type: 'schedule',
      );
    }

    debugPrint('✅ Schedule notification setup complete');
  }

  /// Calculate next occurrence of a weekly class
  DateTime _getNextOccurrence(int dayOfWeek, String timeStr) {
    final now = DateTime.now();
    final timeParts = timeStr.split(':');
    if (timeParts.length < 2) {
      throw FormatException('Invalid time format: $timeStr');
    }
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // App convention: Mon=2..Sun=8; Dart weekday: Mon=1..Sun=7
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
