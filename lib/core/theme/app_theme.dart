import 'package:flutter/material.dart';

enum ThemePreset {
  artha,
  amber,
  serika,
  olive,
  graphite,
  ocean,
  rose,
  forest,
}

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF2E7D32); // Green
  static const Color primaryLight = Color(0xFF60AD5E);
  static const Color primaryDark = Color(0xFF005005);

  static const Color errorColor = Color(0xFFD32F2F); // Red
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      error: errorColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      error: errorColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundDark,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
  );

  static ThemeData lightThemeFor(ThemePreset preset) {
    switch (preset) {
      case ThemePreset.amber:
        return _monkeytypeLightTheme;
      case ThemePreset.graphite:
        return _graphiteLightTheme;
      case ThemePreset.ocean:
        return _oceanLightTheme;
      case ThemePreset.rose:
        return _roseLightTheme;
      case ThemePreset.forest:
        return _forestLightTheme;
      case ThemePreset.artha:
        return lightTheme;
      case ThemePreset.serika:
        return _monkeytypeSerikaLightTheme;
      case ThemePreset.olive:
        return _monkeytypeOliveLightTheme;
    }
  }

  static ThemeData darkThemeFor(ThemePreset preset) {
    switch (preset) {
      case ThemePreset.serika:
        return _monkeytypeSerikaDarkTheme;
      case ThemePreset.olive:
        return _monkeytypeOliveDarkTheme;
      case ThemePreset.amber:
        return _monkeytypeDarkTheme;
      case ThemePreset.graphite:
        return _graphiteDarkTheme;
      case ThemePreset.ocean:
        return _oceanDarkTheme;
      case ThemePreset.rose:
        return _roseDarkTheme;
      case ThemePreset.forest:
        return _forestDarkTheme;
      case ThemePreset.artha:
        return darkTheme;
    }
  }

  static ThemeData _buildMonkeytypeTheme({
    required Color bg,
    required Color surface,
    required Color primary,
    required Color onSurface,
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: isDark ? const Color(0xFF1F1F1F) : const Color(0xFF2E2E2E),
      secondary: primary,
      onSecondary: isDark ? const Color(0xFF1F1F1F) : const Color(0xFF2E2E2E),
      error: isDark ? const Color(0xFFEF5350) : const Color(0xFFD32F2F),
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      fontFamily: 'Segoe UI',
      appBarTheme: AppBarTheme(backgroundColor: bg, foregroundColor: onSurface),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor:
            isDark ? const Color(0xFF1F1F1F) : const Color(0xFF2E2E2E),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primary.withValues(alpha: 0.25),
        labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
        secondaryLabelStyle:
            TextStyle(color: onSurface, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: primary.withValues(alpha: 0.25)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary.withValues(alpha: 0.35)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary.withValues(alpha: 0.35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor:
              isDark ? const Color(0xFF1F1F1F) : const Color(0xFF2E2E2E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: onSurface,
        displayColor: onSurface,
      ),
    );
  }

  static ThemeData get _monkeytypeLightTheme {
    const bg = Color(0xFFF7F3E8);
    const surface = Color(0xFFEFE8D6);
    const primary = Color(0xFFE2B714);
    const on = Color(0xFF323437);
    return _buildMonkeytypeTheme(
      bg: bg,
      surface: surface,
      primary: primary,
      onSurface: on,
      brightness: Brightness.light,
    );
  }

  static ThemeData get _monkeytypeDarkTheme {
    const bg = Color(0xFF323437);
    const surface = Color(0xFF2C2E31);
    const primary = Color(0xFFE2B714);
    const on = Color(0xFFD1D0C5);
    return _buildMonkeytypeTheme(
      bg: bg,
      surface: surface,
      primary: primary,
      onSurface: on,
      brightness: Brightness.dark,
    );
  }

  static ThemeData get _monkeytypeSerikaLightTheme => _buildMonkeytypeTheme(
        bg: const Color(0xFFF4EAD8),
        surface: const Color(0xFFEADFCB),
        primary: const Color(0xFFE2B714),
        onSurface: const Color(0xFF2E2C29),
        brightness: Brightness.light,
      );

  static ThemeData get _monkeytypeSerikaDarkTheme => _buildMonkeytypeTheme(
        bg: const Color(0xFF2C2E31),
        surface: const Color(0xFF26282B),
        primary: const Color(0xFFE2B714),
        onSurface: const Color(0xFFD9D5C8),
        brightness: Brightness.dark,
      );

  static ThemeData get _monkeytypeOliveLightTheme => _buildMonkeytypeTheme(
        bg: const Color(0xFFF2F4EA),
        surface: const Color(0xFFE5E8D9),
        primary: const Color(0xFF7E8F3B),
        onSurface: const Color(0xFF2E3522),
        brightness: Brightness.light,
      );

  static ThemeData get _monkeytypeOliveDarkTheme => _buildMonkeytypeTheme(
        bg: const Color(0xFF2B3124),
        surface: const Color(0xFF242A1F),
        primary: const Color(0xFF94A74A),
        onSurface: const Color(0xFFD4DBC4),
        brightness: Brightness.dark,
      );

  static ThemeData get _graphiteLightTheme => _buildMonkeytypeTheme(
        bg: const Color(0xFFF0F1F3),
        surface: const Color(0xFFE5E7EB),
        primary: const Color(0xFF4B5563),
        onSurface: const Color(0xFF1F2937),
        brightness: Brightness.light,
      );
  static ThemeData get _graphiteDarkTheme => _buildMonkeytypeTheme(
        bg: const Color(0xFF1F2937),
        surface: const Color(0xFF111827),
        primary: const Color(0xFF9CA3AF),
        onSurface: const Color(0xFFE5E7EB),
        brightness: Brightness.dark,
      );

  static ThemeData get _oceanLightTheme => _buildMonkeytypeTheme(
        bg: const Color(0xFFEFF7FA),
        surface: const Color(0xFFDDEFF5),
        primary: const Color(0xFF1D7FA3),
        onSurface: const Color(0xFF123342),
        brightness: Brightness.light,
      );
  static ThemeData get _oceanDarkTheme => _buildMonkeytypeTheme(
        bg: const Color(0xFF0F2B38),
        surface: const Color(0xFF123342),
        primary: const Color(0xFF58B3D2),
        onSurface: const Color(0xFFD3ECF5),
        brightness: Brightness.dark,
      );

  static ThemeData get _roseLightTheme => _buildMonkeytypeTheme(
        bg: const Color(0xFFFCEFF2),
        surface: const Color(0xFFF8DEE5),
        primary: const Color(0xFFC95B7A),
        onSurface: const Color(0xFF4A2030),
        brightness: Brightness.light,
      );
  static ThemeData get _roseDarkTheme => _buildMonkeytypeTheme(
        bg: const Color(0xFF341925),
        surface: const Color(0xFF472333),
        primary: const Color(0xFFE688A3),
        onSurface: const Color(0xFFF8DDE7),
        brightness: Brightness.dark,
      );

  static ThemeData get _forestLightTheme => _buildMonkeytypeTheme(
        bg: const Color(0xFFEDF5EE),
        surface: const Color(0xFFDDEBDF),
        primary: const Color(0xFF3E7C4D),
        onSurface: const Color(0xFF1D3A24),
        brightness: Brightness.light,
      );
  static ThemeData get _forestDarkTheme => _buildMonkeytypeTheme(
        bg: const Color(0xFF1C3222),
        surface: const Color(0xFF24402C),
        primary: const Color(0xFF7EC48F),
        onSurface: const Color(0xFFD8F0DE),
        brightness: Brightness.dark,
      );
}
