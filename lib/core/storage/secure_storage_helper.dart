// lib/core/storage/secure_storage_helper.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  SecureStorageHelper._internal();
  static final SecureStorageHelper instance = SecureStorageHelper._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _sessionKey = 'session_user_id';
  static const String _roleKey    = 'session_user_role';

  Future<void> saveSession({required String userId, required String role}) async {
    await _storage.write(key: _sessionKey, value: userId);
    await _storage.write(key: _roleKey,    value: role);
  }

  Future<String?> getSessionUserId() => _storage.read(key: _sessionKey);
  Future<String?> getSessionRole()   => _storage.read(key: _roleKey);

  Future<void> clearSession() async {
    await _storage.delete(key: _sessionKey);
    await _storage.delete(key: _roleKey);
  }

  Future<bool> hasActiveSession() async {
    final userId = await getSessionUserId();
    return userId != null;
  }
}
