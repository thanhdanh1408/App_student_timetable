import 'package:flutter/material.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/add_notification_usecase.dart';
import '../../domain/usecases/update_notification_usecase.dart';
import '../../domain/usecases/delete_notification_usecase.dart';

class NotificationViewModel with ChangeNotifier {
  final GetNotificationsUsecase _getUsecase;
  final AddNotificationUsecase _addUsecase;
  final UpdateNotificationUsecase _updateUsecase;
  final DeleteNotificationUsecase _deleteUsecase;
  final NotificationService notificationService;

  List<NotificationEntity> _notifications = [];
  String? _error;
  bool _isLoading = false;

  NotificationViewModel({
    required GetNotificationsUsecase get,
    required AddNotificationUsecase add,
    required UpdateNotificationUsecase update,
    required DeleteNotificationUsecase delete,
    required this.notificationService,
  })  : _getUsecase = get,
        _addUsecase = add,
        _updateUsecase = update,
        _deleteUsecase = delete;

  List<NotificationEntity> get notifications => _notifications;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _notifications = await _getUsecase();
      _notifications.sort((a, b) => b.scheduledFor.compareTo(a.scheduledFor));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> add(NotificationEntity notification) async {
    try {
      await _addUsecase(notification);
      await load();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteByKey(int key) async {
    try {
      await _deleteUsecase(key);
      await load();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final notification = _notifications.firstWhere(
        (n) => n.id == id,
        orElse: () => throw Exception('Notification not found'),
      );
      final updatedNotification = NotificationEntity(
        id: notification.id,
        title: notification.title,
        body: notification.body,
        type: notification.type,
        createdAt: notification.createdAt,
        scheduledFor: notification.scheduledFor,
        isRead: true,
        relatedId: notification.relatedId,
      );
      final index = _notifications.indexOf(notification);
      await _updateUsecase(index, updatedNotification);
      await load();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}

// Backward-compatible alias (old naming used across the UI).
