import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/travel_route.dart';
import 'route_media_image.dart';

class RouteCard extends StatelessWidget {
  const RouteCard({
    super.key,
    required this.route,
    required this.isBusy,
    required this.onSave,
    required this.onLike,
    required this.onComments,
    this.onTap,
    this.onDelete,
  });

  final TravelRoute route;
  final bool isBusy;
  final VoidCallback onSave;
  final VoidCallback onLike;
  final VoidCallback onComments;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: RouteMediaImage(
                    source: route.coverImageUrl,
                    fallbackAsset: route.imageAsset,
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      child: Text(
                        route.budgetLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: _OwnerPill(
                    username: route.ownerUsername,
                    avatarUrl: route.ownerAvatarUrl,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    route.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.mutedText,
                          height: 1.35,
                        ),
                  ),
                  if (route.stops.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _StopsPreview(stops: route.stops),
                  ],
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _ActionButton(
                        tooltip: 'Beğen',
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
                      if (onDelete != null)
                        IconButton(
                          tooltip: 'Sil',
                          visualDensity: VisualDensity.compact,
                          onPressed: isBusy ? null : onDelete,
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      const Spacer(),
                      _ActionButton(
                        tooltip: route.isSaved ? 'Kaydı kaldır' : 'Kaydet',
                        icon: route.isSaved
                            ? Icons.bookmark_added_rounded
                            : Icons.bookmark_add_outlined,
                        label: route.savesCount.toString(),
                        color: route.isSaved
                            ? AppTheme.primary
                            : AppTheme.mutedText,
                        onTap: isBusy ? null : onSave,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OwnerPill extends StatelessWidget {
  const _OwnerPill({
    required this.username,
    required this.avatarUrl,
  });

  final String username;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final resolvedAvatar = avatarUrl?.trim();
    final hasAvatar = resolvedAvatar != null && resolvedAvatar.isNotEmpty;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor: Colors.white,
              child: hasAvatar
                  ? ClipOval(
                      child: SizedBox.square(
                        dimension: 20,
                        child: RouteMediaImage(
                          source: resolvedAvatar,
                          fallbackAsset: 'assets/images/aegean-wonders.jpg',
                          enableFullScreen: false,
                        ),
                      ),
                    )
                  : Text(
                      username.isEmpty
                          ? '?'
                          : username.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
            const SizedBox(width: 7),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(
                username.isEmpty ? 'Gezgin' : username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StopsPreview extends StatelessWidget {
  const _StopsPreview({required this.stops});

  final List<RouteStop> stops;

  @override
  Widget build(BuildContext context) {
    final preview = stops.take(3).toList();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final stop in preview)
          Chip(
            visualDensity: VisualDensity.compact,
            avatar: const Icon(Icons.place_outlined, size: 16),
            label: Text(
              stop.cityName.isEmpty ? stop.stopName : stop.cityName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (stops.length > preview.length)
          Chip(
            visualDensity: VisualDensity.compact,
            label: Text('+${stops.length - preview.length}'),
          ),
      ],
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
              Icon(icon, size: 21, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
