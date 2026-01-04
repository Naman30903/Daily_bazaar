import 'package:flutter/material.dart';
import '../../constant/product_detail_theme.dart';

/// Displays price information: current price, MRP (strikethrough),
/// discount badge, and "inclusive of all taxes" text.
class PriceSection extends StatelessWidget {
  const PriceSection({
    super.key,
    required this.price,
    this.mrp,
    this.discountPercent,
    this.showTaxInfo = true,
  });

  /// Current selling price (e.g., "₹78")
  final String price;

  /// Original MRP to show strikethrough (e.g., "₹150")
  final String? mrp;

  /// Discount percentage (e.g., 48 for "48% OFF")
  final int? discountPercent;

  /// Whether to show "Inclusive of all taxes" text
  final bool showTaxInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ProductDetailTheme.space16),
      decoration: const BoxDecoration(
        color: ProductDetailTheme.cardBackground,
        border: Border(
          bottom: BorderSide(
            color: ProductDetailTheme.divider,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Current price
              Text(
                price,
                style: const TextStyle(
                  color: ProductDetailTheme.textPrimary,
                  fontSize: ProductDetailTheme.fontXXLarge,
                  fontWeight: FontWeight.w700,
                ),
              ),

              // MRP
              if (mrp != null) ...[
                const SizedBox(width: ProductDetailTheme.space8),
                Text(
                  'MRP',
                  style: TextStyle(
                    color: ProductDetailTheme.textSecondary.withValues(alpha: 0.7),
                    fontSize: ProductDetailTheme.fontSmall,
                  ),
                ),
                const SizedBox(width: ProductDetailTheme.space4),
                Text(
                  mrp!,
                  style: const TextStyle(
                    color: ProductDetailTheme.textStrikethrough,
                    fontSize: ProductDetailTheme.fontMedium,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: ProductDetailTheme.textStrikethrough,
                  ),
                ),
              ],

              // Discount badge
              if (discountPercent != null && discountPercent! > 0) ...[
                const SizedBox(width: ProductDetailTheme.space8),
                _DiscountBadge(percent: discountPercent!),
              ],
            ],
          ),

          // Tax info
          if (showTaxInfo) ...[
            const SizedBox(height: ProductDetailTheme.space4),
            const Text(
              'Inclusive of all taxes',
              style: TextStyle(
                color: ProductDetailTheme.textMuted,
                fontSize: ProductDetailTheme.fontSmall,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ProductDetailTheme.space6,
        vertical: ProductDetailTheme.space4,
      ),
      decoration: BoxDecoration(
        color: ProductDetailTheme.discountBadgeBg,
        borderRadius: BorderRadius.circular(ProductDetailTheme.radiusSmall),
      ),
      child: Text(
        '$percent% OFF',
        style: const TextStyle(
          color: ProductDetailTheme.discountBadgeText,
          fontSize: ProductDetailTheme.fontXSmall,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
