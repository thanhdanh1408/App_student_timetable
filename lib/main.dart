// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/config/app_routes.dart';

// Firebase
import 'core/services/firebase_service.dart';

// Providers
import 'features/subjects/presentation/viewmodels/subjects_viewmodel.dart';
import 'features/schedule/presentation/viewmodels/schedule_viewmodel.dart';
import 'features/exam/presentation/viewmodels/exam_viewmodel.dart';
import 'features/home/presentation/viewmodels/home_viewmodel.dart';
import 'features/notifications/presentation/viewmodels/notification_viewmodel.dart';
import 'features/notifications/domain/entities/notification_entity.dart';
import 'features/settings/presentation/viewmodels/settings_viewmodel.dart';
import 'core/providers/notification_settings_provider.dart';
import 'core/providers/auth_provider.dart';

// Repository Impl (Data layer)
import 'features/subjects/data/repositories/subjects_repository_impl.dart';
import 'features/schedule/data/repositories/schedule_repository_impl.dart';
import 'features/exam/data/repositories/exam_repository_impl.dart';
import 'features/notifications/data/repositories/notification_repository_impl.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';

// Usecases
import 'features/subjects/domain/usecases/get_subjects_usecase.dart';
import 'features/subjects/domain/usecases/add_subject_usecase.dart';
import 'features/subjects/domain/usecases/update_subject_usecase.dart';
import 'features/subjects/domain/usecases/delete_subject_usecase.dart';
import 'features/schedule/domain/usecases/get_schedules_usecase.dart';
import 'features/schedule/domain/usecases/add_schedule_usecase.dart';
import 'features/schedule/domain/usecases/update_schedule_usecase.dart';
import 'features/schedule/domain/usecases/delete_schedule_usecase.dart';
import 'features/exam/domain/usecases/get_exams_usecase.dart';
import 'features/exam/domain/usecases/add_exam_usecase.dart';
import 'features/exam/domain/usecases/update_exam_usecase.dart';
import 'features/exam/domain/usecases/delete_exam_usecase.dart';
import 'features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'features/notifications/domain/usecases/add_notification_usecase.dart';
import 'features/notifications/domain/usecases/update_notification_usecase.dart';
import 'features/notifications/domain/usecases/delete_notification_usecase.dart';
import 'features/settings/domain/usecases/get_settings_usecase.dart';
import 'features/settings/domain/usecases/save_settings_usecase.dart';
import 'core/services/background_task_handler.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  final firebaseService = FirebaseService();
  await firebaseService.initialize();
  print('✅ Firebase initialized');

  // Khởi tạo NotificationService
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // Khởi tạo Background Task Handler
  final backgroundTaskHandler = BackgroundTaskHandler();
  await backgroundTaskHandler.init();
  await backgroundTaskHandler.registerTasks();

  // Khởi tạo Repositories (Firebase Firestore)
  final subjectsRepo = SubjectsRepositoryImpl();
  final scheduleRepo = ScheduleRepositoryImpl();
  final examRepo = ExamRepositoryImpl();
  final notificationRepo = NotificationRepositoryImpl();
  final settingsRepo = SettingsRepositoryImpl();

  // 3. Khởi tạo Usecases
  final getSubjectsUsecase = GetSubjectsUsecase(subjectsRepo);
  final addSubjectUsecase = AddSubjectUsecase(subjectsRepo);
  final updateSubjectUsecase = UpdateSubjectUsecase(subjectsRepo);
  final deleteSubjectUsecase = DeleteSubjectUsecase(subjectsRepo);

  final getSchedulesUsecase = GetSchedulesUsecase(scheduleRepo);
  final addScheduleUsecase = AddScheduleUsecase(scheduleRepo);
  final updateScheduleUsecase = UpdateScheduleUsecase(scheduleRepo);
  final deleteScheduleUsecase = DeleteScheduleUsecase(scheduleRepo);

  final getExamsUsecase = GetExamsUsecase(examRepo);
  final addExamUsecase = AddExamUsecase(examRepo);
  final updateExamUsecase = UpdateExamUsecase(examRepo);
  final deleteExamUsecase = DeleteExamUsecase(examRepo);

  final getNotificationsUsecase = GetNotificationsUsecase(notificationRepo);
  final addNotificationUsecase = AddNotificationUsecase(notificationRepo);
  final updateNotificationUsecase = UpdateNotificationUsecase(notificationRepo);
  final deleteNotificationUsecase = DeleteNotificationUsecase(notificationRepo);

  // Persist scheduled notifications to Firestore immediately (with their due time).
  // This keeps the in-app list consistent even if the Notifications page is never opened.
  notificationService.onNotificationScheduled = (relatedId, title, body, type, scheduledFor) async {
    try {
      await addNotificationUsecase(
        NotificationEntity(
          title: title,
          body: body,
          type: type,
          createdAt: DateTime.now(),
          scheduledFor: scheduledFor,
          relatedId: relatedId,
          isRead: false,
        ),
      );
    } catch (e) {
      print('❌ Error persisting notification to Firestore: $e');
    }
  };

  final getSettingsUsecase = GetSettingsUsecase(settingsRepo);
  final saveSettingsUsecase = SaveSettingsUsecase(settingsRepo);

  // 4. Create AuthProvider first
  final authProvider = AuthProvider();
  await authProvider.initialize();

  // 5. Initialize routing with auth provider
  AppRoutes.initialize(authProvider);

  // 6. Chạy app
  runApp(
    MultiProvider(
      providers: [
        // Auth - use the already-initialized provider
        ChangeNotifierProvider.value(
          value: authProvider,
        ),

        // Notification Settings
        ChangeNotifierProvider(
          create: (_) {
            final provider = NotificationSettingsProvider();
            provider.init();
            return provider;
          },
        ),

        // Subjects
        ChangeNotifierProvider(
          create: (_) => SubjectsViewModel(
            get: getSubjectsUsecase,
            add: addSubjectUsecase,
            update: updateSubjectUsecase,
            delete: deleteSubjectUsecase,
          )..load(), // Load data on creation
        ),

        // Schedule - needs NotificationSettingsProvider for custom reminder times
        ChangeNotifierProxyProvider<NotificationSettingsProvider, ScheduleViewModel>(
          create: (_) => ScheduleViewModel(
            get: getSchedulesUsecase,
            add: addScheduleUsecase,
            update: updateScheduleUsecase,
            delete: deleteScheduleUsecase,
          )..load(),
          update: (_, notificationSettings, previousScheduleViewModel) =>
              previousScheduleViewModel ?? ScheduleViewModel(
            get: getSchedulesUsecase,
            add: addScheduleUsecase,
            update: updateScheduleUsecase,
            delete: deleteScheduleUsecase,
            notificationSettings: notificationSettings,
          ),
        ),

        // Exam - needs NotificationSettingsProvider for custom reminder times
        ChangeNotifierProxyProvider<NotificationSettingsProvider, ExamViewModel>(
          create: (_) => ExamViewModel(
            get: getExamsUsecase,
            add: addExamUsecase,
            update: updateExamUsecase,
            delete: deleteExamUsecase,
          )..load(),
          update: (_, notificationSettings, previousExamViewModel) =>
              previousExamViewModel ?? ExamViewModel(
            get: getExamsUsecase,
            add: addExamUsecase,
            update: updateExamUsecase,
            delete: deleteExamUsecase,
            notificationSettings: notificationSettings,
          ),
        ),

        // Notifications
        ChangeNotifierProvider(
          create: (_) => NotificationViewModel(
            get: getNotificationsUsecase,
            add: addNotificationUsecase,
            update: updateNotificationUsecase,
            delete: deleteNotificationUsecase,
            notificationService: notificationService,
          )..load(), // Load data on creation
        ),

        // Settings
        ChangeNotifierProvider(
          create: (_) => SettingsViewModel(
            get: getSettingsUsecase,
            save: saveSettingsUsecase,
          ),
        ),

        // Home - tạo với đầy đủ các provider khác
        ChangeNotifierProxyProvider4<SubjectsViewModel, ScheduleViewModel, ExamViewModel, NotificationViewModel, HomeViewModel>(
          create: (_) => HomeViewModel(
            subjectsViewModel: null,
            scheduleViewModel: null,
            examViewModel: null,
            notificationViewModel: null,
          ),
          update: (_, subjectsViewModel, scheduleViewModel, examViewModel, notificationViewModel, previousHomeViewModel) =>
              HomeViewModel(
            subjectsViewModel: subjectsViewModel,
            scheduleViewModel: scheduleViewModel,
            examViewModel: examViewModel,
            notificationViewModel: notificationViewModel,
          ),
        ),
      ],
      child: const AppRoot(),
    ),
  );
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppWidget();
  }
}
