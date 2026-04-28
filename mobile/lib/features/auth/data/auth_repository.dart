import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_store.dart';
import 'auth_session.dart';

class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required TokenStore tokenStore,
  })  : _apiClient = apiClient,
        _tokenStore = tokenStore;

  final ApiClient _apiClient;
  final TokenStore _tokenStore;

  Future<AuthSession?> restoreSession() async {
    final snapshot = await _tokenStore.read();
    if (snapshot == null) {
      return null;
    }

    if (snapshot.isExpired) {
      await _tokenStore.clear();
      return null;
    }

    return AuthSession.fromSnapshot(snapshot);
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      await _apiClient.auth.post<void>(
        '/api/Auth/register',
        data: {
          'username': username.trim(),
          'email': email.trim(),
          'password': password,
        },
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<AuthSession> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiClient.auth.post<Map<String, dynamic>>(
        '/api/Auth/login',
        data: {
          'username': username.trim(),
          'password': password,
        },
      );

      final session = AuthSession.fromJson(response.data!);
      await _tokenStore.save(
        token: session.token,
        username: session.username,
        expiresAt: session.expiresAt,
      );
      return session;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> logout() => _tokenStore.clear();
}
