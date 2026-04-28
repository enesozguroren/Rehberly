import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenSnapshot {
  const TokenSnapshot({
    required this.token,
    required this.username,
    required this.expiresAt,
  });

  final String token;
  final String username;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt.toUtc());
}

class TokenStore {
  TokenStore({
    FlutterSecureStorage? storage,
  }) : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  static const _tokenKey = 'rehberly.jwt';
  static const _usernameKey = 'rehberly.username';
  static const _expiresAtKey = 'rehberly.expiresAt';

  final FlutterSecureStorage _storage;

  Future<void> save({
    required String token,
    required String username,
    required DateTime expiresAt,
  }) async {
    await Future.wait([
      _storage.write(key: _tokenKey, value: token),
      _storage.write(key: _usernameKey, value: username),
      _storage.write(key: _expiresAtKey, value: expiresAt.toUtc().toIso8601String()),
    ]);
  }

  Future<TokenSnapshot?> read() async {
    final values = await Future.wait([
      _storage.read(key: _tokenKey),
      _storage.read(key: _usernameKey),
      _storage.read(key: _expiresAtKey),
    ]);

    final token = values[0];
    final username = values[1];
    final expiresAtRaw = values[2];
    final expiresAt = expiresAtRaw == null ? null : DateTime.tryParse(expiresAtRaw);

    if (token == null || username == null || expiresAt == null) {
      return null;
    }

    return TokenSnapshot(
      token: token,
      username: username,
      expiresAt: expiresAt,
    );
  }

  Future<String?> readToken() async {
    final snapshot = await read();
    if (snapshot == null || snapshot.isExpired) {
      return null;
    }

    return snapshot.token;
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _usernameKey),
      _storage.delete(key: _expiresAtKey),
    ]);
  }
}
