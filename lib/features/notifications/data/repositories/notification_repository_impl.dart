// lib/features/notifications/data/repositories/notification_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '/core/services/firebase_service.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  static final NotificationRepositoryImpl _instance =
      NotificationRepositoryImpl._internal();
  factory NotificationRepositoryImpl() => _instance;
  NotificationRepositoryImpl._internal();

  final FirebaseService _firebase = FirebaseService();

  /// Get Firestore collection reference for notifications
  CollectionReference<Map<String, dynamic>> get _notificationsCollection =>
      _firebase.firestore
          .collection('users')
          .doc(_firebase.currentUserId)
          .collection('notifications');

  @override
  Future<List<NotificationEntity>> getAll() async {
    try {
      if (!_firebase.isAuthenticated) return [];

      final userId = _firebase.currentUserId;
      if (userId == null) return [];

      final nowIso = DateTime.now().toUtc().toIso8601String();

      // Query notifications that are due (scheduled_for <= now)
      final snapshot = await _notificationsCollection
          .where('scheduled_for', isLessThanOrEqualTo: nowIso)
          .orderBy('scheduled_for', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['notification_id'] = doc.id;
        return NotificationEntity.fromJson(data);
      }).toList();
    } catch (e) {
      print('❌ Error loading notifications: $e');
      // Fallback: get all notifications without scheduled_for filter
      try {
        final snapshot = await _notificationsCollection
            .orderBy('created_at', descending: true)
            .get();

        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['notification_id'] = doc.id;
          return NotificationEntity.fromJson(data);
        }).toList();
      } catch (e2) {
        print('❌ Fallback also failed: $e2');
        return [];
      }
    }
  }

  @override
  Future<void> add(NotificationEntity notification) async {
    try {
      if (!_firebase.isAuthenticated) throw Exception('Not authenticated');

      final userId = _firebase.currentUserId;
      if (userId == null) throw Exception('User ID is null');

      final payload = {
        'user_id': userId,
        ...notification.toJson(),
      };

      await _notificationsCollection.add(payload);

      print('✅ Notification added to Firestore');
    } catch (e) {
      print('❌ Error adding notification: $e');
      rethrow;
    }
  }

  Future<String?> _resolveIdFromKey(int key) async {
    final list = await getAll();
    if (key < 0 || key >= list.length) return null;
    return list[key].id;
  }

  @override
  Future<void> update(int key, NotificationEntity notification) async {
    try {
      if (!_firebase.isAuthenticated) throw Exception('Not authenticated');

      final id = notification.id ?? await _resolveIdFromKey(key);
      if (id == null) throw Exception('Notification ID is null');

      final payload = notification.toJson();

      await _notificationsCollection.doc(id).update(payload);

      print('✅ Notification updated in Firestore');
    } catch (e) {
      print('❌ Error updating notification: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(int key) async {
    try {
      if (!_firebase.isAuthenticated) throw Exception('Not authenticated');

      final id = await _resolveIdFromKey(key);
      if (id == null) throw Exception('Notification not found for key=$key');

      await deleteById(id);
    } catch (e) {
      print('❌ Error deleting notification: $e');
      rethrow;
    }
  }

  Future<void> deleteById(String id) async {
    try {
      if (!_firebase.isAuthenticated) throw Exception('Not authenticated');

      await _notificationsCollection.doc(id).delete();

      print('✅ Notification deleted from Firestore');
    } catch (e) {
      print('❌ Error deleting notification by id: $e');
      rethrow;
    }
  }
}
