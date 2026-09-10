import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'access_token';
  static const _nameKey = 'user_name';

  static Future<void> save(String token) =>
      _storage.write(key: _tokenKey, value: token);

  static Future<String?> read() => _storage.read(key: _tokenKey);

  static Future<void> saveName(String name) =>
      _storage.write(key: _nameKey, value: name);

  static Future<String?> readName() => _storage.read(key: _nameKey);

  static Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _nameKey);
  }
}
