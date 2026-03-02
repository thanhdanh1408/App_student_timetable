// lib/features/schedule/domain/entities/schedule_entity.dart
class ScheduleEntity {
  final String? id; // schedule_id from Firestore

  final String? subjectId; // subject_id UUID

  final String? subjectName; // denormalized for display

  final String? teacherName; // denormalized for display

  final int? dayOfWeek;

  final String? startTime;

  final String? endTime;

  final String? location;

  final String? color;

  final bool isEnabled;

  ScheduleEntity({
    this.id,
    this.subjectId,
    this.subjectName,
    this.teacherName,
    this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.location,
    this.color,
    this.isEnabled = true,
  });

  factory ScheduleEntity.fromJson(Map<String, dynamic> json) {
    return ScheduleEntity(
      id: json['schedule_id'] as String?,
      subjectId: json['subject_id'] as String?,
      subjectName: json['subject_name'] as String?,
      teacherName: json['teacher_name'] as String?,
      dayOfWeek: json['day_of_week'] as int?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      location: json['location'] as String?,
      color: json['color'] as String?,
      isEnabled: json['is_enabled'] as bool? ?? true,
    );
  }

  ScheduleEntity copyWith({
    String? id,
    String? subjectId,
    String? subjectName,
    String? teacherName,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? location,
    String? color,
    bool? isEnabled,
  }) {
    return ScheduleEntity(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      teacherName: teacherName ?? this.teacherName,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      color: color ?? this.color,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}