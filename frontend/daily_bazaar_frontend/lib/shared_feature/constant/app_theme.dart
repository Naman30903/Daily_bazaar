import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData dark() {
    const seed = Color(0xFF2ECC71); // brand green (adjust anytime)

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: base.colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: base.colorScheme.surface,
        foregroundColor: base.colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: base.colorScheme.surfaceContainerHighest.withValues(alpha: 0.18),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: base.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: base.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: base.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: base.colorScheme.primary, width: 1.4),
        ),
      ),
    );
  }
}
