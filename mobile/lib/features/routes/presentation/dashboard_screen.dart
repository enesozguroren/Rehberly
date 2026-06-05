import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/async_error_view.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../auth/presentation/session_controller.dart';
import '../../profile/presentation/profile_controller.dart';
import '../../profile/presentation/profile_screen.dart';
import '../data/travel_route.dart';
import '../widgets/comments_sheet.dart';
import '../widgets/route_card.dart';
import '../widgets/search_bar.dart';
import 'create_route_screen.dart';
import 'route_detail_screen.dart';
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
    final routeController = context.read<RouteFeedController>();
    final profileController = context.read<RehberlyProfileController>();
    final username = context.read<SessionController>().session?.username;
    Future.microtask(() async {
      await routeController.loadFeed();
      await routeController.loadSavedRoutes();
      if (username != null && mounted) {
        await profileController.loadProfile(username);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useSidebar = constraints.maxWidth > 600;

        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                if (useSidebar)
                  _DashboardSidebar(
                    selectedIndex: _selectedIndex,
                    onCreateRoute: () => _openCreateRoute(context),
                    onDestinationSelected: _selectDestination,
                  ),
                Expanded(
                  child: Column(
                    children: [
                      if (_selectedIndex != 2)
                        _Header(
                          onSearch: context
                              .read<RouteFeedController>()
                              .setSearchQuery,
                          onFilterTap: () => _showComingSoon(context),
                        ),
                      Expanded(
                        child: IndexedStack(
                          index: _selectedIndex,
                          children: const [
                            _DiscoverTab(),
                            _SavedTab(),
                            ProfileScreen(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: useSidebar
              ? null
              : _DashboardBottomBar(
                  selectedIndex: _selectedIndex,
                  onCreateRoute: () => _openCreateRoute(context),
                  onDestinationSelected: _selectDestination,
                ),
        );
      },
    );
  }

  void _selectDestination(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1) {
      context.read<RouteFeedController>().loadSavedRoutes();
    }
  }

  Future<void> _openCreateRoute(BuildContext context) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<RouteFeedController>(),
          child: const CreateRouteScreen(),
        ),
      ),
    );

    if (created != true || !context.mounted) return;

    setState(() => _selectedIndex = 0);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rota başarıyla oluşturuldu.')),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filtreler API tarafında hazır olduğunda bağlanacak.'),
      ),
    );
  }
}

class _DashboardBottomBar extends StatelessWidget {
  const _DashboardBottomBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onCreateRoute,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onCreateRoute;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 76,
      color: AppTheme.card,
      surfaceTintColor: AppTheme.card,
      child: Row(
        children: [
          Expanded(
            child: _BottomNavItem(
              label: 'Keşfet',
              icon: Icons.explore_outlined,
              selectedIcon: Icons.explore_rounded,
              isSelected: selectedIndex == 0,
              onTap: () => onDestinationSelected(0),
            ),
          ),
          Expanded(
            child: _BottomNavItem(
              label: 'Kayıtlar',
              icon: Icons.bookmark_border_rounded,
              selectedIcon: Icons.bookmark_rounded,
              isSelected: selectedIndex == 1,
              onTap: () => onDestinationSelected(1),
            ),
          ),
          Expanded(
            child: _BottomNavItem(
              label: 'Ekle',
              icon: Icons.add_circle_outline_rounded,
              selectedIcon: Icons.add_circle_rounded,
              isSelected: false,
              onTap: onCreateRoute,
            ),
          ),
          Expanded(
            child: _BottomNavItem(
              label: 'Profil',
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
              isSelected: selectedIndex == 2,
              onTap: () => onDestinationSelected(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardSidebar extends StatelessWidget {
  const _DashboardSidebar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onCreateRoute,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onCreateRoute;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 232,
      decoration: const BoxDecoration(
        color: AppTheme.card,
        border: Border(
          right: BorderSide(color: AppTheme.border),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              ],
            ),
            const SizedBox(height: 28),
            _SidebarDestination(
              label: 'Keşfet',
              icon: Icons.explore_outlined,
              selectedIcon: Icons.explore_rounded,
              isSelected: selectedIndex == 0,
              onTap: () => onDestinationSelected(0),
            ),
            _SidebarDestination(
              label: 'Kayıtlar',
              icon: Icons.bookmark_border_rounded,
              selectedIcon: Icons.bookmark_rounded,
              isSelected: selectedIndex == 1,
              onTap: () => onDestinationSelected(1),
            ),
            _SidebarDestination(
              label: 'Profil',
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
              isSelected: selectedIndex == 2,
              onTap: () => onDestinationSelected(2),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onCreateRoute,
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text('Rota ekle'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const Spacer(),
            Text(
              'Local Web',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.mutedText,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarDestination extends StatelessWidget {
  const _SidebarDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppTheme.primary : AppTheme.mutedText;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(isSelected ? selectedIcon : icon, color: color),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppTheme.primary : AppTheme.mutedText;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: SizedBox(
        height: 58,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? selectedIcon : icon, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
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
    return Consumer<RouteFeedController>(
      builder: (context, routes, _) {
        if (routes.isLoadingFeed && routes.feed.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (routes.errorMessage != null && routes.feed.isEmpty) {
          return AsyncErrorView(
            message: routes.errorMessage!,
            onRetry: routes.loadFeed,
          );
        }

        if (MediaQuery.sizeOf(context).width > 600 &&
            routes.filteredFeed.isNotEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              await routes.loadFeed();
              await routes.loadSavedRoutes();
            },
            child: _RoutesGridView(
              routes: routes.filteredFeed,
              title: 'Rota Akışı',
              trailing: '${routes.filteredFeed.length} rota',
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await routes.loadFeed();
            await routes.loadSavedRoutes();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            children: [
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

        if (MediaQuery.sizeOf(context).width > 600 &&
            routes.savedRoutes.isNotEmpty) {
          return RefreshIndicator(
            onRefresh: routes.loadSavedRoutes,
            child: _RoutesGridView(
              routes: routes.savedRoutes,
              title: 'Kaydedilen Rotalar',
              trailing: '${routes.savedRoutes.length} kayıt',
            ),
          );
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
                  message:
                      'Beğendiğin rotaları kaydederek rütbe akışını başlat.',
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

class _RoutesGridView extends StatelessWidget {
  const _RoutesGridView({
    required this.routes,
    required this.title,
    required this.trailing,
  });

  final List<TravelRoute> routes;
  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1180 ? 3 : 2;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
          sliver: SliverToBoxAdapter(
            child: _SectionHeader(title: title, trailing: trailing),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
          sliver: SliverGrid.builder(
            itemCount: routes.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 430,
            ),
            itemBuilder: (context, index) {
              return _ConnectedRouteCard(route: routes[index]);
            },
          ),
        ),
      ],
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
    final canDelete = route.isOwnedBy(username);

    return RouteCard(
      route: route,
      isBusy: routes.isRouteBusy(route.id),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => RouteDetailScreen(
              routeId: route.id,
              initialRoute: route,
            ),
          ),
        );
      },
      onLike: () async {
        try {
          await context.read<RouteFeedController>().toggleLike(route);
        } on ApiException catch (error) {
          if (!context.mounted) return;
          _showSnack(context, error.message);
        }
      },
      onSave: () async {
        try {
          final saved =
              await context.read<RouteFeedController>().toggleSave(route);
          if (!context.mounted) return;
          if (saved && username != null) {
            await Future<void>.delayed(const Duration(milliseconds: 400));
            if (context.mounted) {
              await context
                  .read<RehberlyProfileController>()
                  .loadProfile(username);
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
      onDelete: canDelete ? () => _confirmDelete(context, route) : null,
    );
  }

  Future<void> _confirmDelete(BuildContext context, TravelRoute route) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rotayı sil'),
        content: const Text('Bu rotayı silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<RouteFeedController>().deleteRoute(route);
      if (!context.mounted) return;
      _showSnack(context, 'Rota silindi.');
    } on ApiException catch (error) {
      if (!context.mounted) return;
      _showSnack(context, error.message);
    } catch (_) {
      if (!context.mounted) return;
      _showSnack(context, 'Rota silinemedi. Lütfen tekrar deneyin.');
    }
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
