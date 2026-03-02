// lib/core/services/background_task_handler.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:workmanager/workmanager.dart';

const String _examReminderTaskId = 'exam_reminder_task';

// Hàm được gọi từ background khi workmanager kích hoạt
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // NOTE: Background task chạy ngoài main thread, không có Context
      // Không gọi NotificationService().initialize() vì sẽ crash
      // (Context bị null)

      // NOTE: Schedule reminders are handled in ScheduleViewModel when users add/update schedules.
      // Only exam reminders use background tasks to check for upcoming exams periodically.

      if (task == _examReminderTaskId) {
        // Background task for periodic exam checks
        // Exam reminders are scheduled when users add/update exams.
        print('✅ Background exam reminder check executed');
      }

      return true;
    } catch (e) {
      print('Error in background task: $e');
      return false;
    }
  });
}

class BackgroundTaskHandler {
  static final BackgroundTaskHandler _instance =
      BackgroundTaskHandler._internal();

  factory BackgroundTaskHandler() {
    return _instance;
  }

  BackgroundTaskHandler._internal();

  // Khởi tạo workmanager
  Future<void> init() async {
    // WorkManager không hoạt động trên web
    if (kIsWeb) {
      print('⚠️ WorkManager skipped on web platform');
      return;
    }
    
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false, // Tắt debug notifications
    );
  }

  // Đăng ký các background tasks
  Future<void> registerTasks() async {
    // WorkManager không hoạt động trên web
    if (kIsWeb) return;
    
    // Exam reminders are scheduled with `flutter_local_notifications` when users add/update exams.
    // A periodic Workmanager task is not needed, and (when debug mode was enabled in older builds)
    // it can spam "Result: Success" notifications.
    //
    // Migration/safety: cancel any previously registered periodic task.
    await Workmanager().cancelByUniqueName(_examReminderTaskId);
  }

  // Hủy tất cả background tasks
  Future<void> cancelAllTasks() async {
    if (kIsWeb) return;
    await Workmanager().cancelAll();
  }

  // Hủy một task cụ thể
  Future<void> cancelTask(String taskName) async {
    if (kIsWeb) return;
    await Workmanager().cancelByUniqueName(taskName);
  }
}
