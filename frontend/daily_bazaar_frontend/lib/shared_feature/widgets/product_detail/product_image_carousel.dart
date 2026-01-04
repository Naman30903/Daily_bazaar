import 'package:flutter/material.dart';
import '../../constant/product_detail_theme.dart';

/// Image carousel for the product detail page.
/// Displays product images with navigation arrows, page indicators,
/// and overlay action buttons (close, wishlist, search, share).
class ProductImageCarousel extends StatefulWidget {
  const ProductImageCarousel({
    super.key,
    required this.imageUrls,
    this.onClose,
    this.onWishlistTap,
    this.onSearchTap,
    this.onShareTap,
    this.isWishlisted = false,
  });

  final List<String> imageUrls;
  final VoidCallback? onClose;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onShareTap;
  final bool isWishlisted;

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPrevious() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNext() {
    if (_currentPage < widget.imageUrls.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = widget.imageUrls.isNotEmpty;

    return Container(
      height: ProductDetailTheme.carouselHeight,
      color: ProductDetailTheme.surfaceElevated,
      child: Stack(
        children: [
          // Image PageView
          if (hasImages)
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: widget.imageUrls.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(ProductDetailTheme.space24),
                  child: Image.network(
                    widget.imageUrls[index],
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                          color: ProductDetailTheme.primaryGreen,
                        ),
                      );
                    },
                  ),
                );
              },
            )
          else
            _buildPlaceholder(),

          // Top action bar
          Positioned(
            top: MediaQuery.of(context).padding.top + ProductDetailTheme.space8,
            left: ProductDetailTheme.space12,
            right: ProductDetailTheme.space12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Close button
                _ActionButton(
                  icon: Icons.keyboard_arrow_down,
                  onTap: widget.onClose,
                ),
                // Right side actions
                Row(
                  children: [
                    _ActionButton(
                      icon: widget.isWishlisted
                          ? Icons.favorite
                          : Icons.favorite_border,
                      onTap: widget.onWishlistTap,
                      iconColor: widget.isWishlisted
                          ? ProductDetailTheme.wishlistActive
                          : null,
                    ),
                    const SizedBox(width: ProductDetailTheme.space8),
                    _ActionButton(
                      icon: Icons.search,
                      onTap: widget.onSearchTap,
                    ),
                    const SizedBox(width: ProductDetailTheme.space8),
                    _ActionButton(
                      icon: Icons.ios_share,
                      onTap: widget.onShareTap,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Left navigation arrow
          if (hasImages && widget.imageUrls.length > 1)
            Positioned(
              left: ProductDetailTheme.space4,
              top: 0,
              bottom: 0,
              child: Center(
                child: _NavigationArrow(
                  icon: Icons.chevron_left,
                  onTap: _currentPage > 0 ? _goToPrevious : null,
                ),
              ),
            ),

          // Right navigation arrow
          if (hasImages && widget.imageUrls.length > 1)
            Positioned(
              right: ProductDetailTheme.space4,
              top: 0,
              bottom: 0,
              child: Center(
                child: _NavigationArrow(
                  icon: Icons.chevron_right,
                  onTap: _currentPage < widget.imageUrls.length - 1
                      ? _goToNext
                      : null,
                ),
              ),
            ),

          // Page indicator dots
          if (hasImages && widget.imageUrls.length > 1)
            Positioned(
              bottom: ProductDetailTheme.space16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.imageUrls.length,
                  (index) => Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentPage
                          ? ProductDetailTheme.textPrimary
                          : ProductDetailTheme.textMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.image_outlined,
        size: 64,
        color: ProductDetailTheme.iconMuted,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ProductDetailTheme.radiusXXLarge),
      child: Container(
        width: ProductDetailTheme.iconButtonSize,
        height: ProductDetailTheme.iconButtonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.3),
        ),
        child: Icon(
          icon,
          color: iconColor ?? ProductDetailTheme.iconDefault,
          size: 24,
        ),
      ),
    );
  }
}

class _NavigationArrow extends StatelessWidget {
  const _NavigationArrow({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isEnabled
              ? ProductDetailTheme.cardBackground.withValues(alpha: 0.8)
              : Colors.transparent,
        ),
        child: Icon(
          icon,
          color: isEnabled
              ? ProductDetailTheme.iconDefault
              : ProductDetailTheme.iconMuted.withValues(alpha: 0.5),
          size: 20,
        ),
      ),
    );
  }
}
