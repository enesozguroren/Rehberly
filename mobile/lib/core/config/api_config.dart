import 'platform_host.dart';

class ApiConfig {
  const ApiConfig({
    required this.authBaseUrl,
    required this.routeBaseUrl,
    required this.profileBaseUrl,
  });

  final String authBaseUrl;
  final String routeBaseUrl;
  final String profileBaseUrl;

  factory ApiConfig.fromEnvironment() {
    const hostOverride = String.fromEnvironment('REHBERLY_API_HOST');
    const useGateway = bool.fromEnvironment(
      'REHBERLY_USE_GATEWAY',
      defaultValue: false,
    );
    const gatewayPort = int.fromEnvironment(
      'REHBERLY_GATEWAY_PORT',
      defaultValue: 5082,
    );
    const authPort = int.fromEnvironment(
      'REHBERLY_AUTH_PORT',
      defaultValue: 5229,
    );
    const routePort = int.fromEnvironment(
      'REHBERLY_ROUTE_PORT',
      defaultValue: 5190,
    );
    const profilePort = int.fromEnvironment(
      'REHBERLY_PROFILE_PORT',
      defaultValue: 5068,
    );

    final host = hostOverride.isEmpty ? defaultApiHost() : hostOverride;

    if (useGateway) {
      final gatewayUrl = _origin(host, gatewayPort);
      return ApiConfig(
        authBaseUrl: gatewayUrl,
        routeBaseUrl: gatewayUrl,
        profileBaseUrl: gatewayUrl,
      );
    }

    return ApiConfig(
      authBaseUrl: _origin(host, authPort),
      routeBaseUrl: _origin(host, routePort),
      profileBaseUrl: _origin(host, profilePort),
    );
  }

  static String _origin(String host, int port) {
    final normalizedHost = host.startsWith('http') ? host : 'http://$host';
    return '$normalizedHost:$port';
  }
}
