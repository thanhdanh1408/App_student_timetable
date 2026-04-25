class GradeEntity {
  final String? id;
  final String? subjectId;
  final String? subjectName;
  final String? teacherName;
  final double score10;
  final int credit;
  final String? note;
  final DateTime? updatedAt;

  GradeEntity({
    this.id,
    this.subjectId,
    this.subjectName,
    this.teacherName,
    required this.score10,
    required this.credit,
    this.note,
    this.updatedAt,
  });

  double get score4 {
    if (score10 >= 8.5) return 4.0;
    if (score10 >= 8.0) return 3.5;
    if (score10 >= 7.0) return 3.0;
    if (score10 >= 6.5) return 2.5;
    if (score10 >= 5.5) return 2.0;
    if (score10 >= 5.0) return 1.5;
    if (score10 >= 4.0) return 1.0;
    return 0.0;
  }

  String get letterGrade {
    if (score10 >= 8.5) return 'A';
    if (score10 >= 8.0) return 'B+';
    if (score10 >= 7.0) return 'B';
    if (score10 >= 6.5) return 'C+';
    if (score10 >= 5.5) return 'C';
    if (score10 >= 5.0) return 'D+';
    if (score10 >= 4.0) return 'D';
    return 'F';
  }

  factory GradeEntity.fromJson(Map<String, dynamic> json) {
    return GradeEntity(
      id: json['grade_id'] as String?,
      subjectId: json['subject_id'] as String?,
      subjectName: json['subject_name'] as String?,
      teacherName: json['teacher_name'] as String?,
      score10: (json['score_10'] as num?)?.toDouble() ?? 0,
      credit: json['credit'] as int? ?? 0,
      note: json['note'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  GradeEntity copyWith({
    String? id,
    String? subjectId,
    String? subjectName,
    String? teacherName,
    double? score10,
    int? credit,
    String? note,
    DateTime? updatedAt,
  }) {
    return GradeEntity(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      teacherName: teacherName ?? this.teacherName,
      score10: score10 ?? this.score10,
      credit: credit ?? this.credit,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
