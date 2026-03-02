// lib/core/providers/notification_settings_provider.dart
import 'package:flutter/foundation.dart';
import '/core/services/firebase_service.dart';
import '/features/settings/data/repositories/settings_repository_impl.dart';

class NotificationSettingsProvider extends ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();
  final SettingsRepositoryImpl _settingsRepo = SettingsRepositoryImpl();

  // Các giá trị mặc định
  int _scheduleReminderMinutes = 15;
  int _examReminderMinutes = 60;
  bool _enableScheduleNotifications = true;
  bool _enableExamNotifications = true;
  bool _isLoading = false;

  // Getters
  int get scheduleReminderMinutes => _scheduleReminderMinutes;
  int get examReminderMinutes => _examReminderMinutes;
  bool get enableScheduleNotifications => _enableScheduleNotifications;
  bool get enableExamNotifications => _enableExamNotifications;
  bool get isLoading => _isLoading;

  // Danh sách các tùy chọn thời gian
  static const List<int> reminderOptions = [5, 10, 15, 30, 60];

  // Khởi tạo provider
  Future<void> init() async {
    await _loadSettings();
  }

  // Tải cài đặt từ Firebase
  Future<void> _loadSettings() async {
    try {
      if (!_firebase.isAuthenticated) return;
      
      _isLoading = true;
      notifyListeners();

      final userId = _firebase.currentUserId;
      if (userId == null) return;

      final settings = await _settingsRepo.getSettings(userId);
      if (settings != null) {
        _scheduleReminderMinutes = settings.scheduleReminderMinutes;
        _examReminderMinutes = settings.examReminderMinutes;
        _enableScheduleNotifications = settings.enableScheduleNotifications;
        _enableExamNotifications = settings.enableExamNotifications;
      }
    } catch (e) {
      debugPrint('❌ Error loading notification settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cập nhật thời gian nhắc nhở cho buổi học
  Future<void> setScheduleReminderMinutes(int minutes) async {
    try {
      _scheduleReminderMinutes = minutes;
      notifyListeners();
      
      await _saveToFirebase();
    } catch (e) {
      debugPrint('❌ Error saving schedule reminder: $e');
    }
  }

  // Cập nhật thời gian nhắc nhở cho lịch thi
  Future<void> setExamReminderMinutes(int minutes) async {
    try {
      _examReminderMinutes = minutes;
      notifyListeners();
      
      await _saveToFirebase();
    } catch (e) {
      debugPrint('❌ Error saving exam reminder: $e');
    }
  }

  // Bật/tắt thông báo buổi học
  Future<void> setEnableScheduleNotifications(bool enable) async {
    try {
      _enableScheduleNotifications = enable;
      notifyListeners();
      
      await _saveToFirebase();
    } catch (e) {
      debugPrint('❌ Error saving schedule notification setting: $e');
    }
  }

  // Bật/tắt thông báo lịch thi
  Future<void> setEnableExamNotifications(bool enable) async {
    try {
      _enableExamNotifications = enable;
      notifyListeners();
      
      await _saveToFirebase();
    } catch (e) {
      debugPrint('❌ Error saving exam notification setting: $e');
    }
  }

  // Lưu tất cả settings vào Firebase
  Future<void> _saveToFirebase() async {
    if (!_firebase.isAuthenticated) return;
    
    final userId = _firebase.currentUserId;
    if (userId == null) return;

    // Load current settings first
    final currentSettings = await _settingsRepo.getSettings(userId);
    if (currentSettings == null) return;

    // Update with new notification settings
    final updatedSettings = currentSettings.copyWith(
      scheduleReminderMinutes: _scheduleReminderMinutes,
      examReminderMinutes: _examReminderMinutes,
      enableScheduleNotifications: _enableScheduleNotifications,
      enableExamNotifications: _enableExamNotifications,
      updatedAt: DateTime.now(),
    );

    await _settingsRepo.saveSettings(updatedSettings);
  }

  // Lấy text mô tả thời gian nhắc nhở
  String getReminderText(int minutes) {
    if (minutes < 60) {
      return '$minutes phút trước';
    } else if (minutes == 60) {
      return '1 giờ trước';
    } else {
      final hours = minutes ~/ 60;
      return '$hours giờ trước';
    }
  }
}
