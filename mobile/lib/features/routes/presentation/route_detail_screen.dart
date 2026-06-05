import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/session_controller.dart';
import '../../profile/presentation/profile_controller.dart';
import '../data/travel_route.dart';
import '../widgets/comments_sheet.dart';
import '../widgets/route_media_image.dart';
import 'route_feed_controller.dart';

class RouteDetailScreen extends StatelessWidget {
  const RouteDetailScreen({
    super.key,
    required this.routeId,
    required this.initialRoute,
  });

  final String routeId;
  final TravelRoute initialRoute;

  @override
  Widget build(BuildContext context) {
    return Consumer<RouteFeedController>(
      builder: (context, routes, _) {
        final route = routes.routeById(routeId) ?? initialRoute;
        final isBusy = routes.isRouteBusy(route.id);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _HeroGallery(route: route),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RouteHeader(route: route),
                      const SizedBox(height: 14),
                      _ActionBar(
                        route: route,
                        isBusy: isBusy,
                        onLike: () => _toggleLike(context, route),
                        onComments: () => _showComments(context, route),
                        onSave: () => _toggleSave(context, route),
                      ),
                      const SizedBox(height: 22),
                      _InfoStrip(route: route),
                      const SizedBox(height: 24),
                      Text(
                        'Açıklama',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        route.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.mutedText,
                              height: 1.45,
                            ),
                      ),
                      if (route.stops.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Duraklar',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        _StopsTimeline(stops: route.stops),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleLike(BuildContext context, TravelRoute route) async {
    final routes = context.read<RouteFeedController>();
    try {
      await routes.toggleLike(route);
    } on ApiException catch (error) {
      if (!context.mounted) return;
      _showSnack(context, error.message);
    }
  }

  Future<void> _toggleSave(BuildContext context, TravelRoute route) async {
    final routes = context.read<RouteFeedController>();
    final profile = context.read<RehberlyProfileController>();
    final username = context.read<SessionController>().session?.username;

    try {
      final saved = await routes.toggleSave(route);
      if (saved && username != null) {
        await Future<void>.delayed(const Duration(milliseconds: 400));
        await profile.loadProfile(username);
      }
    } on ApiException catch (error) {
      if (!context.mounted) return;
      _showSnack(context, error.message);
    }
  }

  void _showComments(BuildContext context, TravelRoute route) {
    final routes = context.read<RouteFeedController>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: routes,
        child: CommentsSheet(route: route),
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _HeroGallery extends StatefulWidget {
  const _HeroGallery({required this.route});

  final TravelRoute route;

  @override
  State<_HeroGallery> createState() => _HeroGalleryState();
}

class _HeroGalleryState extends State<_HeroGallery> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = _galleryImages(widget.route);

    return SliverAppBar(
      pinned: true,
      expandedHeight: 340,
      backgroundColor: AppTheme.background,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: images.length,
              onPageChanged: (value) => setState(() => _page = value),
              itemBuilder: (context, index) {
                return RouteMediaImage(
                  source: images[index],
                  fallbackAsset: widget.route.imageAsset,
                );
              },
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x66000000),
                    Color(0x00000000),
                    Color(0x99000000),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.route.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _BudgetBadge(label: widget.route.budgetLabel),
                ],
              ),
            ),
            if (images.length > 1)
              Positioned(
                bottom: 88,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var index = 0; index < images.length; index++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: index == _page ? 18 : 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: index == _page ? 0.95 : 0.55,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<String?> _galleryImages(TravelRoute route) {
    final coverImage = route.coverImageUrl?.trim();
    return [coverImage == null || coverImage.isEmpty ? null : coverImage];
  }
}

class _RouteHeader extends StatelessWidget {
  const _RouteHeader({required this.route});

  final TravelRoute route;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
          child: Text(
            route.ownerUsername.isEmpty
                ? '?'
                : route.ownerUsername.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                route.ownerUsername.isEmpty ? 'Gezgin' : route.ownerUsername,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                _locationSummary(route),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.mutedText,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _locationSummary(TravelRoute route) {
    final cities = route.stops
        .map((stop) => stop.cityName)
        .where((city) => city.trim().isNotEmpty)
        .toSet()
        .take(3)
        .join(' • ');
    return cities.isEmpty ? 'Rota yaratıcısı' : cities;
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.route,
    required this.isBusy,
    required this.onLike,
    required this.onComments,
    required this.onSave,
  });

  final TravelRoute route;
  final bool isBusy;
  final VoidCallback onLike;
  final VoidCallback onComments;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionButton(
          tooltip: route.isLiked ? 'Beğeniyi kaldır' : 'Beğen',
          icon: route.isLiked
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          label: route.likesCount.toString(),
          color: route.isLiked
              ? Theme.of(context).colorScheme.error
              : AppTheme.mutedText,
          onTap: isBusy ? null : onLike,
        ),
        _ActionButton(
          tooltip: 'Yorumlar',
          icon: Icons.mode_comment_outlined,
          label: route.commentsCount.toString(),
          color: AppTheme.mutedText,
          onTap: onComments,
        ),
        const Spacer(),
        _ActionButton(
          tooltip: route.isSaved ? 'Kaydı kaldır' : 'Kaydet',
          icon: route.isSaved
              ? Icons.bookmark_added_rounded
              : Icons.bookmark_add_outlined,
          label: route.savesCount.toString(),
          color: route.isSaved ? AppTheme.primary : AppTheme.mutedText,
          onTap: isBusy ? null : onSave,
        ),
      ],
    );
  }
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({required this.route});

  final TravelRoute route;

  @override
  Widget build(BuildContext context) {
    final days = route.stops
        .map((stop) => stop.dayNumber)
        .where((day) => day > 0)
        .fold<int>(0, (max, day) => day > max ? day : max);

    return Row(
      children: [
        Expanded(
          child: _InfoTile(
            icon: Icons.payments_outlined,
            label: 'Bütçe',
            value: route.budgetLabel,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _InfoTile(
            icon: Icons.calendar_today_outlined,
            label: 'Süre',
            value: days == 0 ? 'Esnek' : '$days gün',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _InfoTile(
            icon: Icons.route_outlined,
            label: 'Durak',
            value: route.stops.length.toString(),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.card,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppTheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.mutedText,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _StopsTimeline extends StatelessWidget {
  const _StopsTimeline({required this.stops});

  final List<RouteStop> stops;

  @override
  Widget build(BuildContext context) {
    final sortedStops = [...stops]
      ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));

    return Column(
      children: [
        for (final stop in sortedStops)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primary,
                  child: Text(
                    stop.dayNumber > 0 ? stop.dayNumber.toString() : '•',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      border: Border.all(color: AppTheme.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stop.stopName.isEmpty
                                ? stop.cityName
                                : stop.stopName,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          if (stop.cityName.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              stop.cityName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.mutedText,
                                  ),
                            ),
                          ],
                          if (stop.notes.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              stop.notes,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.mutedText,
                                    height: 1.35,
                                  ),
                            ),
                          ],
                          if (stop.photoUrls.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _StopPhotoCarousel(
                              photos: stop.photoUrls,
                              fallbackAsset: 'assets/images/aegean-wonders.jpg',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StopPhotoCarousel extends StatefulWidget {
  const _StopPhotoCarousel({
    required this.photos,
    required this.fallbackAsset,
  });

  final List<String> photos;
  final String fallbackAsset;

  @override
  State<_StopPhotoCarousel> createState() => _StopPhotoCarouselState();
}

class _StopPhotoCarouselState extends State<_StopPhotoCarousel> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.photos.length,
              onPageChanged: (value) => setState(() => _page = value),
              itemBuilder: (context, index) {
                return RouteMediaImage(
                  source: widget.photos[index],
                  fallbackAsset: widget.fallbackAsset,
                );
              },
            ),
          ),
        ),
        if (widget.photos.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var index = 0; index < widget.photos.length; index++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: index == _page ? 18 : 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(
                      alpha: index == _page ? 0.9 : 0.28,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _BudgetBadge extends StatelessWidget {
  const _BudgetBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.tooltip,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: Row(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
