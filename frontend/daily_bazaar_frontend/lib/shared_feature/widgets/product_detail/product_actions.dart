import 'package:flutter/material.dart';
import '../../constant/product_detail_theme.dart';

/// Action rows for product detail: "View product details" expandable
/// and brand "Explore all products" navigation.
class ProductActions extends StatelessWidget {
  const ProductActions({
    super.key,
    this.onViewDetailsTap,
    this.onExploreBrandTap,
    this.brandName,
    this.brandLogoUrl,
    this.isDetailsExpanded = false,
  });

  final VoidCallback? onViewDetailsTap;
  final VoidCallback? onExploreBrandTap;
  final String? brandName;
  final String? brandLogoUrl;
  final bool isDetailsExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ProductDetailTheme.cardBackground,
      child: Column(
        children: [
          // View product details row
          _ActionRow(
            title: 'View product details',
            trailing: Icon(
              isDetailsExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: ProductDetailTheme.primaryGreen,
              size: 20,
            ),
            titleColor: ProductDetailTheme.primaryGreen,
            onTap: onViewDetailsTap,
          ),

          const Divider(
            height: 1,
            color: ProductDetailTheme.divider,
          ),

          // Brand / Explore all products row
          if (brandName != null)
            _BrandRow(
              brandName: brandName!,
              brandLogoUrl: brandLogoUrl,
              onTap: onExploreBrandTap,
            ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.title,
    this.trailing,
    this.titleColor,
    this.onTap,
  });

  final String title;
  final Widget? trailing;
  final Color? titleColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ProductDetailTheme.space16,
          vertical: ProductDetailTheme.space14,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: titleColor ?? ProductDetailTheme.textPrimary,
                fontSize: ProductDetailTheme.fontMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow({
    required this.brandName,
    this.brandLogoUrl,
    this.onTap,
  });

  final String brandName;
  final String? brandLogoUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ProductDetailTheme.space16,
          vertical: ProductDetailTheme.space12,
        ),
        child: Row(
          children: [
            // Brand logo
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ProductDetailTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(ProductDetailTheme.radiusMedium),
                border: Border.all(
                  color: ProductDetailTheme.divider,
                  width: 1,
                ),
              ),
              child: brandLogoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(
                        ProductDetailTheme.radiusMedium - 1,
                      ),
                      child: Image.network(
                        brandLogoUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => _buildLogoPlaceholder(),
                      ),
                    )
                  : _buildLogoPlaceholder(),
            ),
            const SizedBox(width: ProductDetailTheme.space12),

            // Brand info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brandName,
                    style: const TextStyle(
                      color: ProductDetailTheme.textPrimary,
                      fontSize: ProductDetailTheme.fontMedium,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Explore all products',
                    style: TextStyle(
                      color: ProductDetailTheme.textSecondary,
                      fontSize: ProductDetailTheme.fontSmall,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            const Icon(
              Icons.chevron_right,
              color: ProductDetailTheme.iconMuted,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoPlaceholder() {
    return Center(
      child: Text(
        brandName.isNotEmpty ? brandName[0].toUpperCase() : 'B',
        style: const TextStyle(
          color: ProductDetailTheme.textSecondary,
          fontSize: ProductDetailTheme.fontLarge,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
