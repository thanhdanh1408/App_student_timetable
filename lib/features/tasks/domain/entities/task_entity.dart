class TaskEntity {
  final String? id;
  final String title;
  final String? description;
  final String priority;
  final String status;
  final DateTime? dueDate;
  final bool isCompleted;
  final String? notes;
  final DateTime? createdAt;

  TaskEntity({
    this.id,
    required this.title,
    this.description,
    this.priority = 'Medium',
    this.status = 'Todo',
    this.dueDate,
    this.isCompleted = false,
    this.notes,
    this.createdAt,
  });

  factory TaskEntity.fromJson(Map<String, dynamic> json) {
    return TaskEntity(
      id: json['task_id'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      priority: json['priority'] as String? ?? 'Medium',
      status: json['status'] as String? ?? 'Todo',
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      isCompleted: json['is_completed'] as bool? ?? false,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? priority,
    String? status,
    DateTime? dueDate,
    bool? isCompleted,
    String? notes,
    DateTime? createdAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
