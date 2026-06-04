import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keyUserId = 'user_id';
  static const _keyUserRole = 'user_role';
  static const _keyCompanyId = 'company_id';
  static const _keyUserName = 'user_name';
  static const _keyCompanyName = 'company_name';
  static const _keyCompanyCode = 'company_code';
  static const _keyToken = 'auth_token';

  static Future<void> saveUserSession({
    required String userId,
    required String userRole,
    required String companyId,
    required String userName,
    required String companyName,
    required String companyCode,
  }) async {
    await Future.wait([
      _storage.write(key: _keyUserId, value: userId),
      _storage.write(key: _keyUserRole, value: userRole),
      _storage.write(key: _keyCompanyId, value: companyId),
      _storage.write(key: _keyUserName, value: userName),
      _storage.write(key: _keyCompanyName, value: companyName),
      _storage.write(key: _keyCompanyCode, value: companyCode),
      _storage.write(key: _keyToken, value: 'authenticated'),
    ]);
  }

  static Future<String?> getUserId() => _storage.read(key: _keyUserId);
  static Future<String?> getUserRole() => _storage.read(key: _keyUserRole);
  static Future<String?> getCompanyId() => _storage.read(key: _keyCompanyId);
  static Future<String?> getUserName() => _storage.read(key: _keyUserName);
  static Future<String?> getCompanyName() => _storage.read(key: _keyCompanyName);
  static Future<String?> getCompanyCode() => _storage.read(key: _keyCompanyCode);
  static Future<String?> getToken() => _storage.read(key: _keyToken);

  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _keyToken);
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearSession() => _storage.deleteAll();
}
