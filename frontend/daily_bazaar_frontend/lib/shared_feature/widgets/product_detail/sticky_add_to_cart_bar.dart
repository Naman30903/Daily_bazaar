import 'package:flutter/material.dart';
import '../../constant/product_detail_theme.dart';

/// Sticky bottom bar with price summary and "Add to cart" CTA.
/// Must remain fixed at bottom of the screen.
class StickyAddToCartBar extends StatelessWidget {
  const StickyAddToCartBar({
    super.key,
    required this.price,
    this.weight,
    this.mrp,
    this.discountPercent,
    this.onAddToCart,
    this.isLoading = false,
  });

  /// Current price (e.g., "₹78")
  final String price;

  /// Product weight/quantity (e.g., "253 g")
  final String? weight;

  /// Original MRP (e.g., "₹150")
  final String? mrp;

  /// Discount percentage
  final int? discountPercent;

  /// Callback when Add to cart is tapped
  final VoidCallback? onAddToCart;

  /// Whether the button is in loading state
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: ProductDetailTheme.space16,
        right: ProductDetailTheme.space16,
        top: ProductDetailTheme.space12,
        bottom: MediaQuery.of(context).padding.bottom + ProductDetailTheme.space12,
      ),
      decoration: BoxDecoration(
        color: ProductDetailTheme.cardBackground,
        boxShadow: ProductDetailTheme.stickyBarShadow,
      ),
      child: Row(
        children: [
          // Price info (left side)
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weight
                if (weight != null)
                  Text(
                    weight!,
                    style: const TextStyle(
                      color: ProductDetailTheme.textSecondary,
                      fontSize: ProductDetailTheme.fontSmall,
                    ),
                  ),

                const SizedBox(height: ProductDetailTheme.space4),

                // Price row
                Row(
                  children: [
                    // Current price
                    Text(
                      price,
                      style: const TextStyle(
                        color: ProductDetailTheme.textPrimary,
                        fontSize: ProductDetailTheme.fontXLarge,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    // MRP
                    if (mrp != null) ...[
                      const SizedBox(width: ProductDetailTheme.space6),
                      Text(
                        'MRP',
                        style: TextStyle(
                          color: ProductDetailTheme.textSecondary.withValues(alpha: 0.7),
                          fontSize: ProductDetailTheme.fontXSmall,
                        ),
                      ),
                      const SizedBox(width: ProductDetailTheme.space4),
                      Text(
                        mrp!,
                        style: const TextStyle(
                          color: ProductDetailTheme.textStrikethrough,
                          fontSize: ProductDetailTheme.fontSmall,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: ProductDetailTheme.textStrikethrough,
                        ),
                      ),
                    ],

                    // Discount badge
                    if (discountPercent != null && discountPercent! > 0) ...[
                      const SizedBox(width: ProductDetailTheme.space6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ProductDetailTheme.space4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ProductDetailTheme.discountBadgeBg,
                          borderRadius: BorderRadius.circular(
                            ProductDetailTheme.radiusSmall,
                          ),
                        ),
                        child: Text(
                          '$discountPercent% OFF',
                          style: const TextStyle(
                            color: ProductDetailTheme.discountBadgeText,
                            fontSize: ProductDetailTheme.fontXSmall,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 2),

                // Tax info
                const Text(
                  'Inclusive of all taxes',
                  style: TextStyle(
                    color: ProductDetailTheme.textMuted,
                    fontSize: ProductDetailTheme.fontXSmall,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: ProductDetailTheme.space16),

          // Add to cart button (right side)
          SizedBox(
            width: 140,
            height: 48,
            child: FilledButton(
              onPressed: isLoading ? null : onAddToCart,
              style: FilledButton.styleFrom(
                backgroundColor: ProductDetailTheme.primaryGreen,
                foregroundColor: Colors.white,
                disabledBackgroundColor: ProductDetailTheme.primaryGreenDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ProductDetailTheme.radiusMedium,
                  ),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Add to cart',
                      style: TextStyle(
                        fontSize: ProductDetailTheme.fontMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
