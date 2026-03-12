import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class TokenStorage {
  Future<String?> readAuthToken();

  Future<void> writeAuthToken(String token);

  Future<void> clearAuthToken();
}

class SecureStorageHelper implements TokenStorage {
  const SecureStorageHelper({
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  static const String _authTokenKey = 'hostel_auth_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readAuthToken() => _storage.read(key: _authTokenKey);

  @override
  Future<void> writeAuthToken(String token) {
    return _storage.write(key: _authTokenKey, value: token);
  }

  @override
  Future<void> clearAuthToken() => _storage.delete(key: _authTokenKey);
}

class InMemoryTokenStorage implements TokenStorage {
  InMemoryTokenStorage([this._token]);

  String? _token;

  @override
  Future<void> clearAuthToken() async {
    _token = null;
  }

  @override
  Future<String?> readAuthToken() async => _token;

  @override
  Future<void> writeAuthToken(String token) async {
    _token = token;
  }
}
