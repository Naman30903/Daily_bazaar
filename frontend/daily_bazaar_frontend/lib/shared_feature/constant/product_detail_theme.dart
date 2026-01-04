import 'package:flutter/material.dart';

/// Design tokens specific to the Product Detail screen.
/// Centralizes colors, spacing, typography, and border radius for consistency.
abstract final class ProductDetailTheme {
  // ─────────────────────────────────────────────────────────────────────────
  // COLORS
  // ─────────────────────────────────────────────────────────────────────────

  /// Main screen background (very dark)
  static const Color backgroundDark = Color(0xFF0D0D0D);

  /// Card/section background
  static const Color cardBackground = Color(0xFF1A1A1A);

  /// Slightly elevated surface (e.g., product image area)
  static const Color surfaceElevated = Color(0xFF1E1E1E);

  /// Primary green accent (buttons, badges)
  static const Color primaryGreen = Color(0xFF2ECC71);

  /// Darker green for hover/pressed states
  static const Color primaryGreenDark = Color(0xFF27AE60);

  /// Delivery time badge background
  static const Color deliveryBadgeBg = Color(0xFF1B3A2F);

  /// Delivery time badge text
  static const Color deliveryBadgeText = Color(0xFF2ECC71);

  /// Discount badge background (orange-red)
  static const Color discountBadgeBg = Color(0xFF3D2A1A);

  /// Discount badge text
  static const Color discountBadgeText = Color(0xFFFF9500);

  /// Veg indicator green
  static const Color vegIndicator = Color(0xFF2ECC71);

  /// Star rating color
  static const Color starRating = Color(0xFFFFC107);

  /// Primary text (white)
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Secondary text (gray)
  static const Color textSecondary = Color(0xFF9E9E9E);

  /// Muted text (darker gray)
  static const Color textMuted = Color(0xFF6B6B6B);

  /// MRP strikethrough text
  static const Color textStrikethrough = Color(0xFF757575);

  /// Divider color
  static const Color divider = Color(0xFF2A2A2A);

  /// Icon default color
  static const Color iconDefault = Color(0xFFE0E0E0);

  /// Icon muted color
  static const Color iconMuted = Color(0xFF757575);

  /// Wishlist heart (unfilled)
  static const Color wishlistInactive = Color(0xFF9E9E9E);

  /// Wishlist heart (filled - red)
  static const Color wishlistActive = Color(0xFFE53935);

  // ─────────────────────────────────────────────────────────────────────────
  // SPACING SCALE
  // ─────────────────────────────────────────────────────────────────────────

  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space14 = 14.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;

  // ─────────────────────────────────────────────────────────────────────────
  // BORDER RADIUS
  // ─────────────────────────────────────────────────────────────────────────

  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  static const double radiusXXLarge = 24.0;

  // ─────────────────────────────────────────────────────────────────────────
  // FONT SIZES
  // ─────────────────────────────────────────────────────────────────────────

  static const double fontXSmall = 10.0;
  static const double fontSmall = 12.0;
  static const double fontMedium = 14.0;
  static const double fontLarge = 16.0;
  static const double fontXLarge = 18.0;
  static const double fontXXLarge = 20.0;
  static const double fontTitle = 22.0;

  // ─────────────────────────────────────────────────────────────────────────
  // COMPONENT DIMENSIONS
  // ─────────────────────────────────────────────────────────────────────────

  /// Product image carousel height
  static const double carouselHeight = 320.0;

  /// Bottom sticky bar height
  static const double stickyBarHeight = 80.0;

  /// Mini product card width in similar products carousel
  static const double miniCardWidth = 130.0;

  /// Mini product card image height
  static const double miniCardImageHeight = 110.0;

  /// Icon button size in top bar
  static const double iconButtonSize = 40.0;

  // ─────────────────────────────────────────────────────────────────────────
  // SHADOWS
  // ─────────────────────────────────────────────────────────────────────────

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get stickyBarShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          blurRadius: 16,
          offset: const Offset(0, -4),
        ),
      ];
}
