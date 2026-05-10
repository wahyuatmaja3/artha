import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: ArthaApp(),
    ),
  );
}

class ArthaApp extends ConsumerWidget {
  const ArthaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themePreset = ref.watch(themePresetProvider);
    return MaterialApp(
      title: 'Artha Budget',
      theme: AppTheme.lightThemeFor(themePreset),
      darkTheme: AppTheme.darkThemeFor(themePreset),
      themeMode: themeMode,
      home: const AppShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}
