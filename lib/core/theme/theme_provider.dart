import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void toggle(bool isDark) {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemePresetNotifier extends Notifier<ThemePreset> {
  @override
  ThemePreset build() => ThemePreset.artha;

  void setPreset(ThemePreset preset) {
    state = preset;
  }
}

final themePresetProvider =
    NotifierProvider<ThemePresetNotifier, ThemePreset>(ThemePresetNotifier.new);
