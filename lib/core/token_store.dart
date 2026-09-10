import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'access_token';

  static Future<void> save(String token) =>
      _storage.write(key: _tokenKey, value: token);

  static Future<String?> read() => _storage.read(key: _tokenKey);

  static Future<void> clear() => _storage.delete(key: _tokenKey);
}
