import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _keyUserId = 'auth_user_id';
  static const String _keyUserEmail = 'auth_user_email';

  Future<void> saveAuthContext({required String userId, String? email}) async {
    await _storage.write(key: _keyUserId, value: userId);
    if (email != null && email.isNotEmpty) {
      await _storage.write(key: _keyUserEmail, value: email);
    }
  }

  Future<String?> readUserId() => _storage.read(key: _keyUserId);
  Future<String?> readUserEmail() => _storage.read(key: _keyUserEmail);

  Future<void> clearAuthContext() async {
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyUserEmail);
  }
}
