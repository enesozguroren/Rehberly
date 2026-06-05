import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/session_controller.dart';
import 'profile_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: SafeArea(
        child: Consumer<RehberlyProfileController>(
          builder: (context, profile, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _SettingsGroup(
                  children: [
                    SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      value: profile.showRankOnProfile,
                      onChanged: profile.setRankVisibility,
                      secondary: const Icon(Icons.workspace_premium_outlined),
                      title: const Text('Rütbemi Profilimde Göster'),
                      subtitle: const Text(
                        'Rütben ProfileService tarafından otomatik belirlenir.',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _SettingsGroup(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.delete_outline_rounded,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      title: const Text('Hesabı sil'),
                      subtitle:
                          const Text('Bu işlem backend hazır olunca açılacak'),
                      enabled: false,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _SettingsGroup(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.logout_rounded),
                      title: const Text('Çıkış yap'),
                      onTap: () async {
                        final session = context.read<SessionController>();
                        Navigator.of(context).pop();
                        await session.logout();
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.card,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(children: children),
      ),
    );
  }
}
