// lib/features/settings/data/repositories/settings_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '/core/services/firebase_service.dart';
import '../../domain/entities/user_settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final FirebaseService _firebase = FirebaseService();

  /// Get settings document reference for a user
  _settingsDoc(String userId) => _firebase.firestore
      .collection('users')
      .doc(userId)
      .collection('settings')
      .doc('user_settings');

  @override
  Future<UserSettingsEntity?> getSettings(String userId) async {
    try {
      if (!_firebase.isAuthenticated) return null;

      final doc = await _settingsDoc(userId).get();

      if (!doc.exists || doc.data() == null) {
        return _createDefaultSettings(userId);
      }

      return UserSettingsEntity.fromJson(doc.data()!);
    } catch (e) {
      print('❌ Error loading settings: $e');
      return _createDefaultSettings(userId);
    }
  }

  @override
  Future<void> saveSettings(UserSettingsEntity settings) async {
    try {
      if (!_firebase.isAuthenticated) throw Exception('Not authenticated');

      // Set with merge to act like upsert
      await _settingsDoc(settings.userId).set(
        settings.toJson(),
        SetOptions(merge: true),
      );

      print('✅ Settings saved to Firestore');
    } catch (e) {
      print('❌ Error saving settings: $e');
      rethrow;
    }
  }

  UserSettingsEntity _createDefaultSettings(String userId) {
    return UserSettingsEntity(
      userId: userId,
      darkMode: false,
      notifications: true,
      language: 'vi',
      scheduleReminderMinutes: 15,
      examReminderMinutes: 60,
      enableScheduleNotifications: true,
      enableExamNotifications: true,
    );
  }
}
