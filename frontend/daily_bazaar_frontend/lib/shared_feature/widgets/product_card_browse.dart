import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/product_model.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/checkout/quantity_stepper.dart';

class ProductCardBrowse extends StatelessWidget {
  const ProductCardBrowse({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.cartQuantity = 0,
    this.onIncrement,
    this.onDecrement,
  });

  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final int cartQuantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with wishlist button
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: product.primaryImageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: product.primaryImageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => Container(
                                color: cs.surfaceContainerHighest.withValues(
                                  alpha: 0.3,
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: cs.primary,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (_, _, _) =>
                                  _ImagePlaceholder(cs: cs),
                            )
                          : _ImagePlaceholder(cs: cs),
                    ),
                  ),
                  // Wishlist button
                  Positioned(
                    top: 6,
                    right: 6,
                    child: InkWell(
                      onTap: () {
                        // TODO: Toggle wishlist
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: cs.surface.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: cs.shadow.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite_border,
                          size: 18,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Product info
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weight badge
                    if (product.weight != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withValues(
                            alpha: 0.4,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: cs.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.weight!,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontSize: 10,
                                    color: cs.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    // Product name
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ),
                    // Rating
                    if (product.rating != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          ...List.generate(5, (i) {
                            return Icon(
                              i < (product.rating ?? 0).floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 12,
                              color: Colors.amber,
                            );
                          }),
                          const SizedBox(width: 4),
                          Text(
                            product.reviewCount != null
                                ? '(${_formatCount(product.reviewCount!)})'
                                : '',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontSize: 9,
                                  color: cs.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ],
                    // Delivery time
                    if (product.deliveryMinutes != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 12, color: cs.primary),
                          const SizedBox(width: 2),
                          Text(
                            '${product.deliveryMinutes} MINS',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontSize: 10,
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    // Price row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.formattedPrice,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        // Cart add button or quantity stepper
                        _CartAddButton(
                          cartQuantity: cartQuantity,
                          hasVariants: product.hasVariants,
                          variantCount: product.variantCount,
                          onAdd: onAddToCart,
                          onIncrement: onIncrement,
                          onDecrement: onDecrement,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 100000) {
      return '${(count / 100000).toStringAsFixed(2)} lac';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 40,
          color: cs.onSurfaceVariant.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

/// Cart-aware add button that shows quantity stepper when item is in cart
class _CartAddButton extends StatelessWidget {
  const _CartAddButton({
    required this.cartQuantity,
    required this.hasVariants,
    required this.variantCount,
    this.onAdd,
    this.onIncrement,
    this.onDecrement,
  });

  final int cartQuantity;
  final bool hasVariants;
  final int variantCount;
  final VoidCallback? onAdd;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    // If item is in cart, show quantity stepper
    if (cartQuantity > 0) {
      return QuantityStepper(
        quantity: cartQuantity,
        minQuantity: 0, // Allow decrementing to 0 which removes item
        onIncrement: onIncrement ?? () {},
        onDecrement: onDecrement ?? () {},
      );
    }

    // Otherwise show ADD button
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onAdd,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cs.primary, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ADD',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (hasVariants)
              Text(
                '$variantCount options',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  color: cs.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
