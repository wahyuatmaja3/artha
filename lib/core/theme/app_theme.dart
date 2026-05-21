import 'package:flutter/material.dart';
import 'neo_tokens.dart';

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
  static ThemeData lightTheme = _buildNeoTheme(brightness: Brightness.light);
  static ThemeData darkTheme = _buildNeoTheme(brightness: Brightness.dark);

  static ThemeData _buildNeoTheme({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? NeoTokens.darkAccent : NeoTokens.lightAccent,
      onPrimary: isDark ? NeoTokens.darkInk : NeoTokens.lightInk,
      secondary: isDark ? const Color(0xFF4CC9F0) : const Color(0xFF1777B6),
      onSecondary: isDark ? NeoTokens.darkInk : Colors.white,
      error: const Color(0xFFE53935),
      onError: Colors.white,
      surface: isDark ? NeoTokens.darkSurface : NeoTokens.lightSurface,
      onSurface: isDark ? NeoTokens.darkInk : NeoTokens.lightInk,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? NeoTokens.darkBg : NeoTokens.lightBg,
      fontFamily: 'Trebuchet MS',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NeoTokens.radiusMd),
          side: BorderSide(color: scheme.onSurface, width: 2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFFFF8EA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        labelStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
        hintStyle: TextStyle(
          color: scheme.onSurface.withValues(alpha: 0.55),
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.onSurface, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.onSurface, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 3),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: Color(0xFFE53935), width: 2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: Color(0xFFE53935), width: 3),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFFFF8EA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: scheme.onSurface, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: scheme.onSurface, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: scheme.primary, width: 3),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NeoTokens.radiusMd),
          side: BorderSide(color: scheme.onSurface, width: 2),
        ),
      ),
    );
    return base;
  }

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
