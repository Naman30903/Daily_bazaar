import 'package:flutter/material.dart';
import '../models/home_models.dart';
import '../../core/utils/responsive.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  });

  final SuggestedProduct product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);
    final cardWidth = isDesktop
        ? 180.0
        : isTablet
        ? 160.0
        : 140.0;
    final imageHeight = isDesktop
        ? 130.0
        : isTablet
        ? 115.0
        : 100.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: imageHeight,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 40,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '₹${product.price.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.primary,
                            ),
                      ),
                      if (product.originalPrice != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          '₹${product.originalPrice!.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: cs.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: onAddToCart,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Add', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
