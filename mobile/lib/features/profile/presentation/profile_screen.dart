import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/session_controller.dart';
import '../../routes/data/route_photo_picker.dart';
import '../../routes/data/travel_route.dart';
import '../../routes/presentation/route_detail_screen.dart';
import '../../routes/presentation/route_feed_controller.dart';
import '../../routes/widgets/full_screen_image_viewer.dart';
import '../../routes/widgets/route_media_image.dart';
import '../data/user_profile.dart';
import 'profile_controller.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<RehberlyProfileController, RouteFeedController,
        SessionController>(
      builder: (context, profileController, routes, session, _) {
        final username = session.session?.username ?? '';
        final profile =
            profileController.profile ?? UserProfile.fallback(username);
        final userRoutes =
            routes.feed.where((route) => route.isOwnedBy(username)).toList();

        return RefreshIndicator(
          onRefresh: () async {
            if (username.isNotEmpty) {
              await profileController.loadProfile(username);
            }
            await routes.loadFeed();
            await routes.loadSavedRoutes();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                title: Text(
                  profile.username.isEmpty ? 'Profil' : profile.username,
                ),
                actions: [
                  IconButton(
                    tooltip: 'Ayarlar',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: _ProfileHeader(
                  profile: profile,
                  routeCount: userRoutes.length,
                  isLoading: profileController.isLoading,
                  showRank: profileController.showRankOnProfile,
                  onEdit: () => _showEditProfileSheet(context, profile),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _PostsHeaderDelegate(
                  child: const _PostsHeader(),
                ),
              ),
              if (userRoutes.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(18, 28, 18, 28),
                    child: _EmptyPosts(),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 28),
                  sliver: SliverList.builder(
                    itemCount: userRoutes.length,
                    itemBuilder: (context, index) {
                      final route = userRoutes[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _ProfileRouteTile(
                          route: route,
                          isBusy: routes.isRouteBusy(route.id),
                          onDelete: () => _confirmDeleteRoute(context, route),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showEditProfileSheet(BuildContext context, UserProfile profile) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<RehberlyProfileController>(),
        child: _EditProfileSheet(profile: profile),
      ),
    );
  }

  Future<void> _confirmDeleteRoute(
    BuildContext context,
    TravelRoute route,
  ) async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rota silindi.')),
      );
    } on ApiException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profile,
    required this.routeCount,
    required this.isLoading,
    required this.showRank,
    required this.onEdit,
  });

  final UserProfile profile;
  final int routeCount;
  final bool isLoading;
  final bool showRank;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileAvatar(profile: profile, radius: 46),
              const SizedBox(width: 18),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ProfileStat(value: routeCount.toString(), label: 'Rota'),
                    _ProfileStat(
                      value: profile.visitedCityCount.toString(),
                      label: 'Şehir',
                    ),
                    _ProfileStat(
                      value: profile.visitedCountryCount.toString(),
                      label: 'Ülke',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  profile.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              if (isLoading)
                const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            '@${profile.username.isEmpty ? 'gezgin' : profile.username}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.mutedText,
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (profile.bio.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              profile.bio,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.35,
                  ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ProfileChip(
                icon: Icons.explore_outlined,
                label: profile.travelStyle,
              ),
              if (showRank)
                _ProfileChip(
                  icon: Icons.workspace_premium_rounded,
                  label: profile.rankTitle,
                  color: AppTheme.accent,
                ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Profili Düzenle'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.profile,
    required this.radius,
  });

  final UserProfile profile;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final source = profile.profilePictureUrl.trim();
    final hasImage = source.isNotEmpty;

    return GestureDetector(
      onTap: hasImage
          ? () => FullScreenImageViewer.show(
                context,
                source: source,
                fallbackAsset: 'assets/images/aegean-wonders.jpg',
              )
          : null,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.border),
        ),
        child: ClipOval(
          child: hasImage
              ? _AvatarImage(source: source)
              : ColoredBox(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  child: Center(
                    child: Text(
                      profile.displayName.trim().isEmpty
                          ? '?'
                          : profile.displayName
                              .trim()
                              .substring(0, 1)
                              .toUpperCase(),
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: radius * 0.58,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    return RouteMediaImage(
      source: source,
      fallbackAsset: 'assets/images/aegean-wonders.jpg',
      fit: BoxFit.cover,
      enableFullScreen: false,
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.mutedText,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({
    required this.icon,
    required this.label,
    this.color = AppTheme.primary,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostsHeader extends StatelessWidget {
  const _PostsHeader();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(
          top: BorderSide(color: AppTheme.border),
          bottom: BorderSide(color: AppTheme.border),
        ),
      ),
      child: Center(
        child: Text(
          'Rotalar',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
    );
  }
}

class _PostsHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _PostsHeaderDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 44;

  @override
  double get maxExtent => 44;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _PostsHeaderDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}

class _ProfileRouteTile extends StatelessWidget {
  const _ProfileRouteTile({
    required this.route,
    required this.isBusy,
    required this.onDelete,
  });

  final TravelRoute route;
  final bool isBusy;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                RouteMediaImage(
                  source: route.coverImageUrl,
                  fallbackAsset: route.imageAsset,
                  enableFullScreen: false,
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: IconButton.filled(
                    tooltip: 'Fotoğrafı büyüt',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.56),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => FullScreenImageViewer.show(
                      context,
                      source: route.coverImageUrl,
                      fallbackAsset: route.imageAsset,
                    ),
                    icon: const Icon(Icons.zoom_out_map_rounded, size: 18),
                  ),
                ),
                Positioned(
                  left: 10,
                  top: 10,
                  child: IconButton.filled(
                    tooltip: 'Rotayı sil',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.56),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isBusy ? null : onDelete,
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _openDetail(context),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          route.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.mutedText,
                                    height: 1.32,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RouteDetailScreen(
          routeId: route.id,
          initialRoute: route,
        ),
      ),
    );
  }
}

class _EmptyPosts extends StatelessWidget {
  const _EmptyPosts();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
          child: const Icon(
            Icons.add_photo_alternate_outlined,
            color: AppTheme.primary,
            size: 34,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Henüz rota paylaşılmadı',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 5),
        Text(
          'Oluşturduğun rotalar burada görünecek.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mutedText,
              ),
        ),
      ],
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.profile});

  final UserProfile profile;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _photoController = TextEditingController();
  final _travelStyleController = TextEditingController();
  final _photoPicker = RoutePhotoPicker();

  @override
  void initState() {
    super.initState();
    _fullNameController.text = widget.profile.fullName;
    _bioController.text = widget.profile.bio;
    _photoController.text = widget.profile.profilePictureUrl;
    _travelStyleController.text = widget.profile.travelStyle;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    _photoController.dispose();
    _travelStyleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final isUpdating = context.watch<RehberlyProfileController>().isUpdating;

    return Padding(
      padding: EdgeInsets.fromLTRB(18, 16, 18, bottomInset + 18),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Profili Düzenle',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Kapat',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fullNameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ad Soyad boş geçilemez.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bioController,
                minLines: 2,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _photoController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Profil fotoğrafı URL/dosya',
                  prefixIcon: const Icon(Icons.image_outlined),
                  suffixIcon: IconButton(
                    tooltip: 'Galeriden seç',
                    onPressed: isUpdating ? null : _pickProfilePhoto,
                    icon: const Icon(Icons.photo_library_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _travelStyleController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Seyahat stili',
                  prefixIcon: Icon(Icons.explore_outlined),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: isUpdating ? null : _submit,
                icon: isUpdating
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(isUpdating ? 'Kaydediliyor' : 'Kaydet'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickProfilePhoto() async {
    try {
      final photo = await _photoPicker.pickCoverPhoto();
      if (photo == null) return;
      setState(() => _photoController.text = photo.source);
    } on RoutePhotoPickerException catch (error) {
      final message = error.isPermissionDenied
          ? 'Galeri izni verilmedi. Fotoğraf eklemek için izinleri kontrol edin.'
          : 'Galeri açılamadı. Lütfen tekrar deneyin.';
      _showSnack(message);
    }
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    try {
      await context.read<RehberlyProfileController>().updateProfile(
            fullName: _fullNameController.text,
            bio: _bioController.text,
            profilePictureUrl: _photoController.text,
            travelStyle: _travelStyleController.text,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      _showSnack('Profil güncellendi.');
    } on ApiException catch (error) {
      if (!mounted) return;
      _showSnack(error.message);
    } on PlatformException {
      if (!mounted) return;
      _showSnack('Profil güncellenemedi. Lütfen tekrar deneyin.');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
