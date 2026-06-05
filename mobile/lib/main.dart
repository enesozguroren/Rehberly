import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/api_config.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_store.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/session_controller.dart';
import 'features/profile/data/profile_repository.dart';
import 'features/profile/presentation/profile_controller.dart';
import 'features/routes/data/route_repository.dart';
import 'features/routes/presentation/dashboard_screen.dart';
import 'features/routes/presentation/route_feed_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStore = TokenStore();
  final apiConfig = ApiConfig.fromEnvironment();
  final apiClient = ApiClient(
    config: apiConfig,
    tokenStore: tokenStore,
  );

  runApp(
    RehberlyApp(
      tokenStore: tokenStore,
      apiClient: apiClient,
    ),
  );
}

class RehberlyApp extends StatelessWidget {
  const RehberlyApp({
    super.key,
    required this.tokenStore,
    required this.apiClient,
  });

  final TokenStore tokenStore;
  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TokenStore>.value(value: tokenStore),
        Provider<ApiClient>.value(value: apiClient),
        Provider<AuthRepository>(
          create: (_) => AuthRepository(
            apiClient: apiClient,
            tokenStore: tokenStore,
          ),
        ),
        Provider<RouteRepository>(
          create: (_) => RouteRepository(apiClient),
        ),
        Provider<ProfileRepository>(
          create: (_) => ProfileRepository(apiClient),
        ),
        ChangeNotifierProvider<SessionController>(
          create: (context) =>
              SessionController(context.read<AuthRepository>())..bootstrap(),
        ),
        ChangeNotifierProvider<RouteFeedController>(
          create: (context) => RouteFeedController(
            routeRepository: context.read<RouteRepository>(),
            profileRepository: context.read<ProfileRepository>(),
          ),
        ),
        ChangeNotifierProvider<RehberlyProfileController>(
          create: (context) => RehberlyProfileController(
            context.read<ProfileRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Rehberly',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: Consumer<SessionController>(
          builder: (context, session, _) {
            if (session.isBootstrapping) {
              return const _SplashScreen();
            }

            return session.isAuthenticated
                ? const DashboardScreen()
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
