// lib/features/subjects/domain/entities/subject_entity.dart
class SubjectEntity {
  final String? id; // Document ID from Firestore

  final String subjectName;

  final String? teacherName;

  final String? color; // Màu sắc môn học (hex color string)

  final int? credit;

  SubjectEntity({
    this.id,
    required this.subjectName,
    this.teacherName,
    this.color,
    this.credit,
  });

  factory SubjectEntity.fromJson(Map<String, dynamic> json) {
    return SubjectEntity(
      id: json['subject_id'] as String?,
      subjectName: json['subject_name'] as String,
      teacherName: json['teacher_name'] as String?,
      color: json['color'] as String?,
      credit: json['credit'] as int?,
    );
  }

  SubjectEntity copyWith({
    String? id,
    String? subjectName,
    String? teacherName,
    String? color,
    int? credit,
  }) {
    return SubjectEntity(
      id: id ?? this.id,
      subjectName: subjectName ?? this.subjectName,
      teacherName: teacherName ?? this.teacherName,
      color: color ?? this.color,
      credit: credit ?? this.credit,
    );
  }
}