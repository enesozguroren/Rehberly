import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/async_error_view.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../auth/presentation/session_controller.dart';
import '../../profile/presentation/profile_controller.dart';
import '../../profile/presentation/profile_summary_card.dart';
import '../data/travel_route.dart';
import '../widgets/comments_sheet.dart';
import '../widgets/route_card.dart';
import '../widgets/search_bar.dart';
import 'route_feed_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _loadedInitialData = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedInitialData) return;

    _loadedInitialData = true;
    final username = context.read<SessionController>().session?.username;
    Future.microtask(() async {
      await context.read<RouteFeedController>().loadFeed();
      await context.read<RouteFeedController>().loadSavedRoutes();
      if (username != null && mounted) {
        await context.read<RehberlyProfileController>().loadProfile(username);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              onSearch: context.read<RouteFeedController>().setSearchQuery,
              onFilterTap: () => _showComingSoon(context),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: const [
                  _DiscoverTab(),
                  _SavedTab(),
                  _ProfileTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          if (index == 1) {
            context.read<RouteFeedController>().loadSavedRoutes();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Keşfet',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border_rounded),
            selectedIcon: Icon(Icons.bookmark_rounded),
            label: 'Kayıtlar',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filtreler API tarafında hazır olduğunda bağlanacak.')),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onSearch,
    required this.onFilterTap,
  });

  final ValueChanged<String> onSearch;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(
          bottom: BorderSide(color: AppTheme.border),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.explore_rounded, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Text(
                  'Rehberly',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const Spacer(),
                IconButton.filledTonal(
                  tooltip: 'Konum',
                  onPressed: () {},
                  icon: const Icon(Icons.place_outlined),
                ),
              ],
            ),
            const SizedBox(height: 14),
            RouteSearchBar(
              onChanged: onSearch,
              onFilterTap: onFilterTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoverTab extends StatelessWidget {
  const _DiscoverTab();

  @override
  Widget build(BuildContext context) {
    return Consumer3<RouteFeedController, RehberlyProfileController, SessionController>(
      builder: (context, routes, profile, session, _) {
        if (routes.isLoadingFeed && routes.feed.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (routes.errorMessage != null && routes.feed.isEmpty) {
          return AsyncErrorView(
            message: routes.errorMessage!,
            onRetry: routes.loadFeed,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await routes.loadFeed();
            await routes.loadSavedRoutes();
            final username = session.session?.username;
            if (username != null) {
              await profile.loadProfile(username);
            }
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            children: [
              ProfileSummaryCard(
                profile: profile.profile,
                routesSaved: routes.savedRoutes.length,
                isLoading: profile.isLoading,
              ),
              const SizedBox(height: 24),
              _SectionHeader(
                title: 'Rota Akışı',
                trailing: '${routes.filteredFeed.length} rota',
              ),
              const SizedBox(height: 12),
              if (routes.filteredFeed.isEmpty)
                const EmptyState(
                  icon: Icons.travel_explore_rounded,
                  title: 'Rota bulunamadı',
                  message: 'Aramayı değiştir veya daha sonra tekrar dene.',
                )
              else
                ...routes.filteredFeed.map(
                  (route) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ConnectedRouteCard(route: route),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SavedTab extends StatelessWidget {
  const _SavedTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<RouteFeedController>(
      builder: (context, routes, _) {
        if (routes.isLoadingSaved && routes.savedRoutes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: routes.loadSavedRoutes,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            children: [
              _SectionHeader(
                title: 'Kaydedilen Rotalar',
                trailing: '${routes.savedRoutes.length} kayıt',
              ),
              const SizedBox(height: 12),
              if (routes.savedRoutes.isEmpty)
                const EmptyState(
                  icon: Icons.bookmark_add_outlined,
                  title: 'Henüz kayıt yok',
                  message: 'Beğendiğin rotaları kaydederek rütbe akışını başlat.',
                )
              else
                ...routes.savedRoutes.map(
                  (route) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ConnectedRouteCard(route: route),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Consumer3<RehberlyProfileController, RouteFeedController, SessionController>(
      builder: (context, profile, routes, session, _) {
        final username = session.session?.username;

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: [
            ProfileSummaryCard(
              profile: profile.profile,
              routesSaved: routes.savedRoutes.length,
              isLoading: profile.isLoading,
            ),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hesap',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.refresh_rounded),
                      title: const Text('Profili yenile'),
                      subtitle: const Text('RabbitMQ rütbe güncellemelerini getir'),
                      onTap: username == null
                          ? null
                          : () => profile.loadProfile(username),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.logout_rounded),
                      title: const Text('Çıkış yap'),
                      onTap: context.read<SessionController>().logout,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ConnectedRouteCard extends StatelessWidget {
  const _ConnectedRouteCard({required this.route});

  final TravelRoute route;

  @override
  Widget build(BuildContext context) {
    final routes = context.watch<RouteFeedController>();
    final username = context.read<SessionController>().session?.username;

    return RouteCard(
      route: route,
      isBusy: routes.isRouteBusy(route.id),
      onLike: () async {
        try {
          await context.read<RouteFeedController>().likeRoute(route);
        } on ApiException catch (error) {
          if (!context.mounted) return;
          _showSnack(context, error.message);
        }
      },
      onSave: () async {
        try {
          final saved = await context.read<RouteFeedController>().toggleSave(route);
          if (!context.mounted) return;
          if (saved && username != null) {
            await Future<void>.delayed(const Duration(milliseconds: 400));
            if (context.mounted) {
              await context.read<RehberlyProfileController>().loadProfile(username);
            }
          }
        } on ApiException catch (error) {
          if (!context.mounted) return;
          _showSnack(context, error.message);
        }
      },
      onComments: () {
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => ChangeNotifierProvider.value(
            value: context.read<RouteFeedController>(),
            child: CommentsSheet(route: route),
          ),
        );
      },
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.trailing,
  });

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        Text(
          trailing,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.mutedText,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
