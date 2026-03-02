// lib/features/settings/domain/entities/user_settings_entity.dart
class UserSettingsEntity {
  final String userId;
  final bool darkMode;
  final bool notifications;
  final String language; // 'vi', 'en'
  final int scheduleReminderMinutes;
  final int examReminderMinutes;
  final bool enableScheduleNotifications;
  final bool enableExamNotifications;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSettingsEntity({
    required this.userId,
    this.darkMode = false,
    this.notifications = true,
    this.language = 'vi',
    this.scheduleReminderMinutes = 15,
    this.examReminderMinutes = 60,
    this.enableScheduleNotifications = true,
    this.enableExamNotifications = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory UserSettingsEntity.fromJson(Map<String, dynamic> json) {
    return UserSettingsEntity(
      userId: json['user_id'] as String,
      darkMode: json['dark_mode'] as bool? ?? false,
      notifications: json['notifications'] as bool? ?? true,
      language: json['language'] as String? ?? 'vi',
      scheduleReminderMinutes: json['schedule_reminder_minutes'] as int? ?? 15,
      examReminderMinutes: json['exam_reminder_minutes'] as int? ?? 60,
      enableScheduleNotifications: json['enable_schedule_notifications'] as bool? ?? true,
      enableExamNotifications: json['enable_exam_notifications'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'dark_mode': darkMode,
      'notifications': notifications,
      'language': language,
      'schedule_reminder_minutes': scheduleReminderMinutes,
      'exam_reminder_minutes': examReminderMinutes,
      'enable_schedule_notifications': enableScheduleNotifications,
      'enable_exam_notifications': enableExamNotifications,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserSettingsEntity copyWith({
    String? userId,
    bool? darkMode,
    bool? notifications,
    String? language,
    int? scheduleReminderMinutes,
    int? examReminderMinutes,
    bool? enableScheduleNotifications,
    bool? enableExamNotifications,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettingsEntity(
      userId: userId ?? this.userId,
      darkMode: darkMode ?? this.darkMode,
      notifications: notifications ?? this.notifications,
      language: language ?? this.language,
      scheduleReminderMinutes: scheduleReminderMinutes ?? this.scheduleReminderMinutes,
      examReminderMinutes: examReminderMinutes ?? this.examReminderMinutes,
      enableScheduleNotifications: enableScheduleNotifications ?? this.enableScheduleNotifications,
      enableExamNotifications: enableExamNotifications ?? this.enableExamNotifications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
