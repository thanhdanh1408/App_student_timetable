// lib/features/notifications/domain/entities/notification_entity.dart
class NotificationEntity {
  final String? id; // Document ID from Firestore
  final String title;
  final String body;
  final String type; // 'exam', 'schedule', 'general'
  final DateTime createdAt;
  final DateTime scheduledFor;
  final bool isRead;
  final String? relatedId; // ID of related entity (exam id, schedule id, etc.)

  NotificationEntity({
    this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    required this.scheduledFor,
    this.isRead = false,
    this.relatedId,
  });

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.parse(json['created_at'] as String);
    final scheduledForRaw = json['scheduled_for'] as String?;
    final scheduledFor = scheduledForRaw != null ? DateTime.parse(scheduledForRaw) : createdAt;

    return NotificationEntity(
      id: json['notification_id'] as String?,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      createdAt: createdAt,
      scheduledFor: scheduledFor,
      isRead: json['is_read'] as bool? ?? false,
      relatedId: json['related_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'notification_id': id,
      'title': title,
      'body': body,
      'type': type,
      'created_at': createdAt.toUtc().toIso8601String(),
      'scheduled_for': scheduledFor.toUtc().toIso8601String(),
      'is_read': isRead,
      'related_id': relatedId,
    };
  }

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    DateTime? createdAt,
    DateTime? scheduledFor,
    bool? isRead,
    String? relatedId,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this.relatedId,
    );
  }
}
