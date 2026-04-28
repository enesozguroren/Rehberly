import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../storage/token_store.dart';

class ApiClient {
  ApiClient({
    required ApiConfig config,
    required TokenStore tokenStore,
  })  : _tokenStore = tokenStore,
        auth = Dio(_baseOptions(config.authBaseUrl)),
        route = Dio(_baseOptions(config.routeBaseUrl)),
        profile = Dio(_baseOptions(config.profileBaseUrl)) {
    _attachAuth(auth);
    _attachAuth(route);
    _attachAuth(profile);
  }

  final TokenStore _tokenStore;
  final Dio auth;
  final Dio route;
  final Dio profile;

  static BaseOptions _baseOptions(String baseUrl) {
    return BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 12),
      sendTimeout: const Duration(seconds: 12),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
  }

  void _attachAuth(Dio dio) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStore.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }
}
