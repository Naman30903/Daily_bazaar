import 'package:flutter/material.dart';
import '../../constant/product_detail_theme.dart';

/// Displays product information: title, weight, veg indicator,
/// delivery time badge, and star rating with review count.
class ProductInfoCard extends StatelessWidget {
  const ProductInfoCard({
    super.key,
    required this.name,
    this.weight,
    this.isVeg = true,
    this.deliveryMinutes,
    this.rating,
    this.reviewCount,
  });

  final String name;
  final String? weight;
  final bool isVeg;
  final int? deliveryMinutes;
  final double? rating;
  final int? reviewCount;

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
          // Delivery time and rating row
          Row(
            children: [
              // Delivery time badge
              if (deliveryMinutes != null) ...[
                _DeliveryTimeBadge(minutes: deliveryMinutes!),
                const SizedBox(width: ProductDetailTheme.space12),
              ],
              // Star rating
              if (rating != null) _StarRating(rating: rating!, reviewCount: reviewCount),
            ],
          ),
          const SizedBox(height: ProductDetailTheme.space12),

          // Product name with veg indicator
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: ProductDetailTheme.textPrimary,
                    fontSize: ProductDetailTheme.fontXLarge,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: ProductDetailTheme.space8),
              // Veg indicator
              _VegIndicator(isVeg: isVeg),
            ],
          ),

          // Weight
          if (weight != null) ...[
            const SizedBox(height: ProductDetailTheme.space4),
            Text(
              weight!,
              style: const TextStyle(
                color: ProductDetailTheme.textSecondary,
                fontSize: ProductDetailTheme.fontMedium,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeliveryTimeBadge extends StatelessWidget {
  const _DeliveryTimeBadge({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ProductDetailTheme.space8,
        vertical: ProductDetailTheme.space4,
      ),
      decoration: BoxDecoration(
        color: ProductDetailTheme.deliveryBadgeBg,
        borderRadius: BorderRadius.circular(ProductDetailTheme.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time_filled,
            size: 14,
            color: ProductDetailTheme.deliveryBadgeText,
          ),
          const SizedBox(width: ProductDetailTheme.space4),
          Text(
            '$minutes MINS',
            style: const TextStyle(
              color: ProductDetailTheme.deliveryBadgeText,
              fontSize: ProductDetailTheme.fontSmall,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({
    required this.rating,
    this.reviewCount,
  });

  final double rating;
  final int? reviewCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stars
        ...List.generate(5, (index) {
          final starValue = index + 1;
          IconData icon;
          if (rating >= starValue) {
            icon = Icons.star;
          } else if (rating >= starValue - 0.5) {
            icon = Icons.star_half;
          } else {
            icon = Icons.star_border;
          }
          return Icon(
            icon,
            size: 16,
            color: ProductDetailTheme.starRating,
          );
        }),
        // Review count
        if (reviewCount != null) ...[
          const SizedBox(width: ProductDetailTheme.space4),
          Text(
            '($reviewCount)',
            style: const TextStyle(
              color: ProductDetailTheme.textSecondary,
              fontSize: ProductDetailTheme.fontSmall,
            ),
          ),
        ],
      ],
    );
  }
}

class _VegIndicator extends StatelessWidget {
  const _VegIndicator({required this.isVeg});

  final bool isVeg;

  @override
  Widget build(BuildContext context) {
    final color = isVeg
        ? ProductDetailTheme.vegIndicator
        : const Color(0xFFE53935); // Red for non-veg

    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
