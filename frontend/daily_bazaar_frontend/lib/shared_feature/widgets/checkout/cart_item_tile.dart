import 'package:daily_bazaar_frontend/shared_feature/models/checkout_models.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/checkout/quantity_stepper.dart';
import 'package:flutter/material.dart';

/// Individual cart item tile
class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.cartItem,
    required this.onIncrement,
    required this.onDecrement,
    this.onMoveToWishlist,
  });

  final CartItem cartItem;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback? onMoveToWishlist;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final product = cartItem.product;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 28,
                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (product.weight != null)
                  Text(
                    product.weight!,
                    style: textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 6),
                if (onMoveToWishlist != null)
                  GestureDetector(
                    onTap: onMoveToWishlist,
                    child: Text(
                      'Move to wishlist',
                      style: textTheme.bodySmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Price and quantity stepper
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Price
              Row(
                children: [
                  if (cartItem.formattedTotalMrp != null &&
                      cartItem.totalSavingsCents != null) ...[
                    Text(
                      cartItem.formattedTotalMrp!,
                      style: textTheme.bodySmall?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    cartItem.formattedTotalPrice,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Quantity stepper
              QuantityStepper(
                quantity: cartItem.quantity,
                onIncrement: onIncrement,
                onDecrement: onDecrement,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
