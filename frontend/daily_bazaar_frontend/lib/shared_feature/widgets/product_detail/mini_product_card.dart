import 'package:flutter/material.dart';
import '../../constant/product_detail_theme.dart';

/// Mini product card for similar products carousel.
/// Displays product image, wishlist heart overlay, and ADD button.
class MiniProductCard extends StatelessWidget {
  const MiniProductCard({
    super.key,
    required this.imageUrl,
    this.onTap,
    this.onAddTap,
    this.onWishlistTap,
    this.isWishlisted = false,
  });

  final String imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onAddTap;
  final VoidCallback? onWishlistTap;
  final bool isWishlisted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: ProductDetailTheme.miniCardWidth,
        decoration: BoxDecoration(
          color: ProductDetailTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(ProductDetailTheme.radiusLarge),
          border: Border.all(
            color: ProductDetailTheme.divider,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image with wishlist overlay
            Stack(
              children: [
                // Product image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(ProductDetailTheme.radiusLarge - 1),
                  ),
                  child: SizedBox(
                    height: ProductDetailTheme.miniCardImageHeight,
                    width: double.infinity,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildPlaceholder();
                      },
                    ),
                  ),
                ),

                // Wishlist heart
                Positioned(
                  top: ProductDetailTheme.space6,
                  right: ProductDetailTheme.space6,
                  child: GestureDetector(
                    onTap: onWishlistTap,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: isWishlisted
                            ? ProductDetailTheme.wishlistActive
                            : ProductDetailTheme.wishlistInactive,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ADD button
            Padding(
              padding: const EdgeInsets.all(ProductDetailTheme.space8),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onAddTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ProductDetailTheme.primaryGreen,
                    side: const BorderSide(
                      color: ProductDetailTheme.primaryGreen,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: ProductDetailTheme.space8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ProductDetailTheme.radiusMedium,
                      ),
                    ),
                  ),
                  child: const Text(
                    'ADD',
                    style: TextStyle(
                      fontSize: ProductDetailTheme.fontSmall,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: ProductDetailTheme.cardBackground,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 32,
          color: ProductDetailTheme.iconMuted,
        ),
      ),
    );
  }
}
