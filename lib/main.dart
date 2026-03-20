import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/theme/app_theme.dart';
import 'data/remote/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: ArthaApp(),
    ),
  );
}

class ArthaApp extends StatelessWidget {
  const ArthaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Artha Budget',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const AppShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}
