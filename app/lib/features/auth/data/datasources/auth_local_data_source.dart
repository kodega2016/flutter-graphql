import 'package:app/core/storage/secure_storage_service.dart';

abstract class AuthLocalDataSource {
  Future<void> saveAccessToken(String token);
  Future<String?> getSavedToken();
  Future<void> clearAccessToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService secureStorageService;
  const AuthLocalDataSourceImpl(this.secureStorageService);

  @override
  Future<void> saveAccessToken(String token) {
    return secureStorageService.saveAccessToken(token);
  }

  @override
  Future<String?> getSavedToken() {
    return secureStorageService.getAccessToken();
  }

  @override
  Future<void> clearAccessToken() {
    return secureStorageService.clearAccessToken();
  }
}
