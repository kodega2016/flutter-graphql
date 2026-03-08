import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage storage;
  const SecureStorageService(this.storage);

  static const _accessTokenKey = 'access_token';

  Future<void> saveAccessToken(String token) async {
    await storage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return storage.read(key: _accessTokenKey);
  }

  Future<void> clearAccessToken() async {
    await storage.delete(key: _accessTokenKey);
  }
}
