import 'package:flutter/material.dart';
import '../../domain/entities/user_settings_entity.dart';
import '../../domain/usecases/get_settings_usecase.dart';
import '../../domain/usecases/save_settings_usecase.dart';

class SettingsViewModel with ChangeNotifier {
  final GetSettingsUsecase _getUsecase;
  final SaveSettingsUsecase _saveUsecase;

  UserSettingsEntity? _settings;
  String? _error;
  bool _isLoading = false;

  SettingsViewModel({
    required GetSettingsUsecase get,
    required SaveSettingsUsecase save,
  })  : _getUsecase = get,
        _saveUsecase = save;

  UserSettingsEntity? get settings => _settings;
  String? get error => _error;
  bool get isLoading => _isLoading;

  bool get darkMode => _settings?.darkMode ?? false;
  bool get notifications => _settings?.notifications ?? true;
  String get language => _settings?.language ?? 'vi';

  Future<void> load(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _settings = await _getUsecase(userId);
      if (_settings == null) {
        _settings = UserSettingsEntity(userId: userId);
        await _saveUsecase(_settings!);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setDarkMode(bool value) async {
    try {
      if (_settings != null) {
        final updated = _settings!.copyWith(
          darkMode: value,
          updatedAt: DateTime.now(),
        );
        await _saveUsecase(updated);
        _settings = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> setNotifications(bool value) async {
    try {
      if (_settings != null) {
        final updated = _settings!.copyWith(
          notifications: value,
          updatedAt: DateTime.now(),
        );
        await _saveUsecase(updated);
        _settings = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> setLanguage(String lang) async {
    try {
      if (_settings != null) {
        final updated = _settings!.copyWith(
          language: lang,
          updatedAt: DateTime.now(),
        );
        await _saveUsecase(updated);
        _settings = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}

// Backward-compatible alias (old naming used across the UI).
