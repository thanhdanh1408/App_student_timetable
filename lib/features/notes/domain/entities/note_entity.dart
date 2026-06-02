class NoteEntity {
  final String? id;
  final String title;
  final String content;
  final String? subjectId;
  final String? subjectName;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteEntity({
    this.id,
    required this.title,
    required this.content,
    this.subjectId,
    this.subjectName,
    this.tags = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory NoteEntity.fromJson(Map<String, dynamic> json) {
    return NoteEntity(
      id: json['note_id'] as String?,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      subjectId: json['subject_id'] as String?,
      subjectName: json['subject_name'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
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
      'note_id': id,
      'title': title,
      'content': content,
      'subject_id': subjectId,
      'subject_name': subjectName,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  NoteEntity copyWith({
    String? id,
    String? title,
    String? content,
    String? subjectId,
    String? subjectName,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
