// lib/features/exam/presentation/providers/exam_controller.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/core/services/notification_service.dart';
import '../../domain/entities/exam_entity.dart';
import '../../domain/usecases/add_exam_usecase.dart';
import '../../domain/usecases/delete_exam_usecase.dart';
import '../../domain/usecases/update_exam_usecase.dart';
import 'exam_provider.dart';

/// StateNotifier for managing exam mutations (add/update/delete)
class ExamController extends StateNotifier<AsyncValue<List>> {
  final AddExamUsecase _addUsecase;
  final UpdateExamUsecase _updateUsecase;
  final DeleteExamUsecase _deleteUsecase;
  final Ref _ref;

  ExamController({
    required AddExamUsecase addUsecase,
    required UpdateExamUsecase updateUsecase,
    required DeleteExamUsecase deleteUsecase,
    required Ref ref,
  })  : _addUsecase = addUsecase,
        _updateUsecase = updateUsecase,
        _deleteUsecase = deleteUsecase,
        _ref = ref,
        super(const AsyncValue.loading());

  /// Add a new exam
  Future<void> addExam(ExamEntity exam) async {
    state = const AsyncValue.loading();
    try {
      final newId = await _addUsecase.call(exam);
      final addedExam = exam.copyWith(id: newId);
      // Schedule notification for the new exam
      await _scheduleNotificationForExam(addedExam);
      // Invalidate the exams list provider to trigger refresh
      _ref.invalidate(examsListProvider);
      state = const AsyncValue.data([]);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Update an existing exam
  Future<void> updateExam(ExamEntity exam) async {
    state = const AsyncValue.loading();
    try {
      await _updateUsecase.call(exam);
      // Cancel old notification and reschedule
      if (exam.id != null) {
        await NotificationService().cancelNotification(exam.id!);
      }
      await _scheduleNotificationForExam(exam);
      // Invalidate the exams list provider to trigger refresh
      _ref.invalidate(examsListProvider);
      state = const AsyncValue.data([]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Delete an exam
  Future<void> deleteExam(String examId) async {
    state = const AsyncValue.loading();
    try {
      await _deleteUsecase.call(examId);
      // Cancel notification
      await NotificationService().cancelNotification(examId);
      // Invalidate the exams list provider to trigger refresh
      _ref.invalidate(examsListProvider);
      state = const AsyncValue.data([]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Schedule notification for an exam.
  /// Uses default reminder of 60 minutes (1 hour) before exam.
  Future<void> _scheduleNotificationForExam(ExamEntity exam) async {
    debugPrint('📝 [ExamController] Scheduling notification for ${exam.subjectName}, ID: ${exam.id}');

    if (exam.id == null || exam.examDate == null || exam.examTime == null) {
      debugPrint('❌ Missing required fields for exam notification');
      return;
    }

    // Default reminder: 60 minutes (1 hour) before exam
    const reminderMinutes = 60;

    final timeParts = exam.examTime!.split(':');
    if (timeParts.length < 2) {
      debugPrint('❌ Invalid examTime format: ${exam.examTime}');
      return;
    }
    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    if (hour == null || minute == null) {
      debugPrint('❌ Invalid examTime values: ${exam.examTime}');
      return;
    }

    final examDateTime = DateTime(
      exam.examDate!.year,
      exam.examDate!.month,
      exam.examDate!.day,
      hour,
      minute,
    );

    final notificationTime = examDateTime.subtract(const Duration(minutes: reminderMinutes));

    debugPrint('📝 Subject: ${exam.subjectName}');
    debugPrint('📝 Exam date/time: $examDateTime');
    debugPrint('📝 Notification time: $notificationTime');
    debugPrint('📝 Current time: ${DateTime.now()}');
    debugPrint('📝 Minutes until notification: ${notificationTime.difference(DateTime.now()).inMinutes}');

    final now = DateTime.now();

    // Build notification body
    String body = 'Giờ thi: ${exam.examTime}${exam.examRoom != null && exam.examRoom!.isNotEmpty ? " • Phòng: ${exam.examRoom}" : ""}';
    if (exam.notes != null && exam.notes!.isNotEmpty) {
      body += '\nGhi chú: ${exam.notes}';
    }

    if (notificationTime.isBefore(now.add(const Duration(seconds: 30)))) {
      debugPrint('📌 Notification time close/past, showing immediately!');
      
      await NotificationService().showImmediateNotification(
        id: exam.id!,
        title: '📝 Sắp đến giờ thi: ${exam.subjectName}',
        body: body,
        payload: 'exam_${exam.id}',
        type: 'exam',
      );
    } else {
      await NotificationService().scheduleNotification(
        id: exam.id!,
        title: '📝 Sắp đến giờ thi: ${exam.subjectName}',
        body: body,
        scheduledTime: notificationTime,
        payload: 'exam_${exam.id}',
        type: 'exam',
      );
    }

    debugPrint('✅ Exam notification setup complete');
  }
}
