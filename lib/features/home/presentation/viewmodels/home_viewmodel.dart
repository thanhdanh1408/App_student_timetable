import 'package:flutter/material.dart';
import '/features/subjects/presentation/viewmodels/subjects_viewmodel.dart';
import '/features/schedule/presentation/viewmodels/schedule_viewmodel.dart';
import '/features/exam/presentation/viewmodels/exam_viewmodel.dart';
import '/features/notifications/presentation/viewmodels/notification_viewmodel.dart';

class HomeSummary {
  final int subjectCount;
  final int scheduleTodayCount;
  final int upcomingExamCount;
  final int notificationCount;
  final List<String> todaySchedules;
  final List<String> upcomingExams;

  HomeSummary({
    required this.subjectCount,
    required this.scheduleTodayCount,
    required this.upcomingExamCount,
    required this.notificationCount,
    required this.todaySchedules,
    required this.upcomingExams,
  });
}

class HomeViewModel with ChangeNotifier {
  bool _isLoading = false;
  HomeSummary _summary = HomeSummary(
    subjectCount: 0,
    scheduleTodayCount: 0,
    upcomingExamCount: 0,
    notificationCount: 0,
    todaySchedules: [],
    upcomingExams: [],
  );

  SubjectsViewModel? _subjectsViewModel;
  ScheduleViewModel? _scheduleViewModel;
  ExamViewModel? _examViewModel;
  NotificationViewModel? _notificationViewModel;

  bool get isLoading => _isLoading;
  HomeSummary get summary => _summary;

  HomeViewModel({
    SubjectsViewModel? subjectsViewModel,
    ScheduleViewModel? scheduleViewModel,
    ExamViewModel? examViewModel,
    NotificationViewModel? notificationViewModel,
  }) {
    updateDependencies(
      subjectsViewModel,
      scheduleViewModel,
      examViewModel,
      notificationViewModel,
    );
  }

  /// Update dependency references without creating a new instance.
  /// Called by ChangeNotifierProxyProvider4's `update` callback.
  void updateDependencies(
    SubjectsViewModel? subjectsViewModel,
    ScheduleViewModel? scheduleViewModel,
    ExamViewModel? examViewModel,
    NotificationViewModel? notificationViewModel,
  ) {
    // Remove old listeners first to prevent leaks
    _subjectsViewModel?.removeListener(_onDependenciesChange);
    _scheduleViewModel?.removeListener(_onDependenciesChange);
    _examViewModel?.removeListener(_onDependenciesChange);
    _notificationViewModel?.removeListener(_onDependenciesChange);

    // Update references
    _subjectsViewModel = subjectsViewModel;
    _scheduleViewModel = scheduleViewModel;
    _examViewModel = examViewModel;
    _notificationViewModel = notificationViewModel;

    // Add new listeners
    _subjectsViewModel?.addListener(_onDependenciesChange);
    _scheduleViewModel?.addListener(_onDependenciesChange);
    _examViewModel?.addListener(_onDependenciesChange);
    _notificationViewModel?.addListener(_onDependenciesChange);

    // Reload summary with new data
    Future.microtask(() => loadSummary());
  }

  void _onDependenciesChange() {
    loadSummary();
  }

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return 'N/A';
    try {
      // Convert HH:mm:ss to HH:mm
      final parts = time.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
      return time;
    } catch (e) {
      return time;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    try {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  void dispose() {
    _subjectsViewModel?.removeListener(_onDependenciesChange);
    _scheduleViewModel?.removeListener(_onDependenciesChange);
    _examViewModel?.removeListener(_onDependenciesChange);
    _notificationViewModel?.removeListener(_onDependenciesChange);
    super.dispose();
  }

  Future<void> loadSummary() async {
    print('🏠 [HomeViewModel] Starting loadSummary...');
    _isLoading = true;
    // Only notify if there are listeners
    if (hasListeners) {
      notifyListeners();
    }

    try {
      final subjects = _subjectsViewModel?.subjects ?? [];
      final schedules = _scheduleViewModel?.schedules ?? [];
      final exams = _examViewModel?.exams ?? [];
      final notifications = _notificationViewModel?.notifications ?? [];

      print('🏠 [HomeViewModel] Data loaded: subjects=${subjects.length}, schedules=${schedules.length}, exams=${exams.length}, notifications=${notifications.length}');

      final now = DateTime.now();
      final todayDayOfWeek = now.weekday;

      print('🏠 [HomeViewModel] Today weekday: $todayDayOfWeek (checking for dayOfWeek ${todayDayOfWeek + 1})');

      final todaySchedules = schedules
          .where((s) => s.dayOfWeek == todayDayOfWeek + 1)
          .map((s) {
            final startTime = _formatTime(s.startTime);
            final endTime = _formatTime(s.endTime);
            return "${s.subjectName ?? 'N/A'}|${s.teacherName ?? 'N/A'}|$startTime - $endTime|${s.location ?? 'N/A'}";
          })
          .toList();

      print('🏠 [HomeViewModel] Today schedules: ${todaySchedules.length}');

      final upcomingExams = exams.where((e) {
        try {
          if (e.examDate == null) return false;
          final diff = e.examDate!.difference(now).inDays;
          return diff >= 0 && diff <= 3;
        } catch (_) {
          return false;
        }
      }).map((e) {
        final examDate = _formatDate(e.examDate);
        final examTime = _formatTime(e.examTime);
        return "${e.subjectName ?? 'N/A'}|${e.examName ?? 'N/A'}|$examDate|$examTime";
      }).toList();

      print('🏠 [HomeViewModel] Upcoming exams: ${upcomingExams.length}');

      _summary = HomeSummary(
        subjectCount: subjects.length,
        scheduleTodayCount: todaySchedules.length,
        upcomingExamCount: upcomingExams.length,
        notificationCount: notifications.length,
        todaySchedules: todaySchedules,
        upcomingExams: upcomingExams,
      );

      print('✅ [HomeViewModel] Summary created successfully');
    } catch (e) {
      print('❌ [HomeViewModel] Error creating summary: $e');
      debugPrint("HomeViewModel error: $e");
      _summary = HomeSummary(
        subjectCount: 0,
        scheduleTodayCount: 0,
        upcomingExamCount: 0,
        notificationCount: 0,
        todaySchedules: [],
        upcomingExams: [],
      );
    }

    _isLoading = false;
    // Check again before notifying
    if (hasListeners) {
      notifyListeners();
    }
  }
}
