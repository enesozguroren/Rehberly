import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehberly_mobile/main.dart';
import 'package:rehberly_mobile/core/storage/token_store.dart';
import 'package:rehberly_mobile/core/network/api_client.dart';
import 'package:rehberly_mobile/core/config/api_config.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Create dummy dependencies
    final tokenStore = TokenStore();
    final apiConfig = ApiConfig(
      authBaseUrl: 'http://localhost:5001',
      routeBaseUrl: 'http://localhost:5002',
      profileBaseUrl: 'http://localhost:5003',
    );
    final apiClient = ApiClient(config: apiConfig, tokenStore: tokenStore);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      RehberlyApp(
        tokenStore: tokenStore,
        apiClient: apiClient,
      ),
    );

    // Verify that the app builds without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
