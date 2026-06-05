import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/user_profile.dart';

class ProfileSummaryCard extends StatelessWidget {
  const ProfileSummaryCard({
    super.key,
    required this.profile,
    required this.routesSaved,
    this.isLoading = false,
  });

  final UserProfile? profile;
  final int routesSaved;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final current = profile ?? UserProfile.fallback('Gezgin');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _Avatar(profile: current),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        current.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.explore_outlined,
                            size: 16,
                            color: AppTheme.mutedText,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              current.travelStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppTheme.mutedText),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.workspace_premium_rounded,
                            size: 18,
                            color: AppTheme.accent,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              current.rankTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (isLoading)
                            const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                _StatItem(
                  value: current.visitedCityCount.toString(),
                  label: 'Şehir',
                ),
                const _VerticalDivider(),
                _StatItem(
                  value: current.visitedCountryCount.toString(),
                  label: 'Ülke',
                ),
                const _VerticalDivider(),
                _StatItem(
                  value: routesSaved.toString(),
                  label: 'Kayıt',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final url = profile.profilePictureUrl;
    final hasRemoteAvatar = url.startsWith('http');

    return CircleAvatar(
      radius: 31,
      backgroundColor: AppTheme.primary.withValues(alpha: 0.14),
      backgroundImage: hasRemoteAvatar ? NetworkImage(url) : null,
      child: hasRemoteAvatar
          ? null
          : Text(
              profile.displayName.trim().isEmpty
                  ? '?'
                  : profile.displayName.trim().substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
            ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.mutedText,
                ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38,
      color: AppTheme.border,
    );
  }
}
