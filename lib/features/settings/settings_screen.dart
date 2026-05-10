import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import 'manage_wallets_screen.dart';
import 'manage_categories_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _themePresetLabel(ThemePreset preset) {
    switch (preset) {
      case ThemePreset.amber:
        return 'Amber';
      case ThemePreset.serika:
        return 'Serika';
      case ThemePreset.olive:
        return 'Olive';
      case ThemePreset.graphite:
        return 'Graphite';
      case ThemePreset.ocean:
        return 'Ocean';
      case ThemePreset.rose:
        return 'Rose';
      case ThemePreset.forest:
        return 'Forest';
      case ThemePreset.artha:
        return 'Artha Default';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themePreset = ref.watch(themePresetProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Account', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.user),
            title: const Text('Profile'),
            trailing: const FaIcon(FontAwesomeIcons.chevronRight, size: 14),
            onTap: () {},
          ),
          const Divider(),
          const ListTile(
            title: Text('Preferences', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          SwitchListTile(
            secondary: const FaIcon(FontAwesomeIcons.moon),
            title: const Text('Dark Mode'),
            value: isDark,
            onChanged: (val) {
              ref.read(themeModeProvider.notifier).toggle(val);
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.palette),
            title: const Text('Theme Preset'),
            subtitle: Text(_themePresetLabel(themePreset)),
            trailing: DropdownButton<ThemePreset>(
              value: themePreset,
              underline: const SizedBox.shrink(),
              onChanged: (value) {
                if (value == null) return;
                ref.read(themePresetProvider.notifier).setPreset(value);
              },
              items: const [
                DropdownMenuItem(
                  value: ThemePreset.artha,
                  child: Text('Artha Default'),
                ),
                DropdownMenuItem(
                  value: ThemePreset.amber,
                  child: Text('Amber'),
                ),
                DropdownMenuItem(
                  value: ThemePreset.serika,
                  child: Text('Serika'),
                ),
                DropdownMenuItem(
                  value: ThemePreset.olive,
                  child: Text('Olive'),
                ),
                DropdownMenuItem(
                  value: ThemePreset.graphite,
                  child: Text('Graphite'),
                ),
                DropdownMenuItem(
                  value: ThemePreset.ocean,
                  child: Text('Ocean'),
                ),
                DropdownMenuItem(
                  value: ThemePreset.rose,
                  child: Text('Rose'),
                ),
                DropdownMenuItem(
                  value: ThemePreset.forest,
                  child: Text('Forest'),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.wallet),
            title: const Text('Manage Wallets'),
            trailing: const FaIcon(FontAwesomeIcons.chevronRight, size: 14),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ManageWalletsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Manage Categories'),
            trailing: const FaIcon(FontAwesomeIcons.chevronRight, size: 14),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ManageCategoriesScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
