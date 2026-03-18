import 'package:flutter/material.dart';

/// Premium dark theme palette for Daily Bazaar.
///
/// Design principles:
/// - Dark blue-gray surfaces (not pure black) for depth and warmth
/// - Soft emerald primary for freshness without eye strain
/// - Warm neutrals for text hierarchy
/// - Carefully calibrated contrast ratios for readability
abstract final class AppTheme {
  // ── Core palette tokens ──────────────────────────────────────────────
  static const Color _seed = Color(0xFF34D399); // soft emerald
  static const Color _surface = Color(0xFF0F1117); // very dark navy
  static const Color _surfaceContainer = Color(0xFF181B23);
  static const Color _surfaceContainerHigh = Color(0xFF1E2230);
  static const Color _outline = Color(0xFF2A3040);
  static const Color _outlineVariant = Color(0xFF353D50);
  static const Color _onSurface = Color(0xFFF1F5F9); // warm white
  static const Color _onSurfaceVariant = Color(0xFF94A3B8); // slate

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
      surface: _surface,
      onSurface: _onSurface,
      onSurfaceVariant: _onSurfaceVariant,
      surfaceContainerHighest: _surfaceContainerHigh,
      outline: _outline,
      outlineVariant: _outlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _surface,
      appBarTheme: AppBarTheme(
        backgroundColor: _surface,
        foregroundColor: _onSurface,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: _surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      dividerTheme: DividerThemeData(
        color: _outlineVariant.withValues(alpha: 0.4),
        thickness: 0.5,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _surfaceContainer,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: _onSurfaceVariant,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _surfaceContainerHigh,
        contentTextStyle: const TextStyle(color: _onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: _surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _outlineVariant.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _outlineVariant.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
    );
  }
}
