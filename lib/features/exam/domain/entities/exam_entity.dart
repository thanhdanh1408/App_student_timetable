// lib/features/exam/domain/entities/exam_entity.dart
class ExamEntity {
  final String? id; // exam_id UUID

  final String? subjectId; // subject_id UUID

  final String? subjectName; // denormalized for display

  final String? teacherName; // denormalized for display

  final DateTime? examDate;

  final String? examTime;

  final String? examName;

  final String? examRoom;

  final String? color;

  final String? notes;

  final bool isCompleted;

  ExamEntity({
    this.id,
    this.subjectId,
    this.subjectName,
    this.teacherName,
    this.examDate,
    this.examTime,
    this.examName,
    this.examRoom,
    this.color,
    this.notes,
    this.isCompleted = false,
  });

  factory ExamEntity.fromJson(Map<String, dynamic> json) {
    return ExamEntity(
      id: json['exam_id'] as String?,
      subjectId: json['subject_id'] as String?,
      subjectName: json['subject_name'] as String?,
      teacherName: json['teacher_name'] as String?,
      examDate: json['exam_date'] != null ? DateTime.parse(json['exam_date'] as String) : null,
      examTime: json['exam_time'] as String?,
      examName: json['exam_name'] as String?,
      examRoom: json['exam_room'] as String?,
      color: json['color'] as String?,
      notes: json['notes'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  ExamEntity copyWith({
    String? id,
    String? subjectId,
    String? subjectName,
    String? teacherName,
    DateTime? examDate,
    String? examTime,
    String? examName,
    String? examRoom,
    String? color,
    String? notes,
    bool? isCompleted,
  }) {
    return ExamEntity(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      teacherName: teacherName ?? this.teacherName,
      examDate: examDate ?? this.examDate,
      examTime: examTime ?? this.examTime,
      examName: examName ?? this.examName,
      examRoom: examRoom ?? this.examRoom,
      color: color ?? this.color,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}