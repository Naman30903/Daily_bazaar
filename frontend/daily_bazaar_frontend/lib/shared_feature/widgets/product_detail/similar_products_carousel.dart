import 'package:flutter/material.dart';
import '../../constant/product_detail_theme.dart';
import '../../models/product_model.dart';
import 'mini_product_card.dart';

/// Horizontally scrollable carousel of similar products.
class SimilarProductsCarousel extends StatelessWidget {
  const SimilarProductsCarousel({
    super.key,
    required this.products,
    this.title = 'Similar products',
    this.onProductTap,
    this.onAddTap,
    this.onWishlistTap,
    this.wishlistedIds = const {},
  });

  final List<Product> products;
  final String title;
  final void Function(Product product)? onProductTap;
  final void Function(Product product)? onAddTap;
  final void Function(Product product)? onWishlistTap;
  final Set<String> wishlistedIds;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: ProductDetailTheme.cardBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ProductDetailTheme.space16,
              ProductDetailTheme.space16,
              ProductDetailTheme.space16,
              ProductDetailTheme.space12,
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: ProductDetailTheme.textPrimary,
                fontSize: ProductDetailTheme.fontLarge,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Horizontal scroll list
          SizedBox(
            height: ProductDetailTheme.miniCardImageHeight + 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: ProductDetailTheme.space16,
              ),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(
                width: ProductDetailTheme.space12,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                final imageUrl = product.primaryImageUrl ?? '';
                final isWishlisted = wishlistedIds.contains(product.id);

                return MiniProductCard(
                  imageUrl: imageUrl,
                  isWishlisted: isWishlisted,
                  onTap: () => onProductTap?.call(product),
                  onAddTap: () => onAddTap?.call(product),
                  onWishlistTap: () => onWishlistTap?.call(product),
                );
              },
            ),
          ),

          const SizedBox(height: ProductDetailTheme.space16),
        ],
      ),
    );
  }
}
