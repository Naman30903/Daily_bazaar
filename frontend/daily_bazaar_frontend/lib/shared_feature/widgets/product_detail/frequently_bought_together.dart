import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../provider/cart_provider.dart';
import '../../constant/product_detail_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Frequently Bought Together" section that shows a bundle deal.
/// Encourages users to add multiple products at once, increasing order value.
class FrequentlyBoughtTogether extends ConsumerStatefulWidget {
  const FrequentlyBoughtTogether({
    super.key,
    required this.mainProduct,
    required this.bundleProducts,
  });

  final Product mainProduct;
  final List<Product> bundleProducts;

  @override
  ConsumerState<FrequentlyBoughtTogether> createState() =>
      _FrequentlyBoughtTogetherState();
}

class _FrequentlyBoughtTogetherState
    extends ConsumerState<FrequentlyBoughtTogether>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slideAnim;
  final Set<int> _selectedIndices = {};

  @override
  void initState() {
    super.initState();
    // Select all by default
    for (int i = 0; i < widget.bundleProducts.length; i++) {
      _selectedIndices.add(i);
    }
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _slideAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _bundleTotalCents {
    int total = widget.mainProduct.priceCents;
    for (final i in _selectedIndices) {
      total += widget.bundleProducts[i].priceCents;
    }
    return total;
  }

  int get _bundleMrpCents {
    int total = widget.mainProduct.mrpCents ?? widget.mainProduct.priceCents;
    for (final i in _selectedIndices) {
      final p = widget.bundleProducts[i];
      total += p.mrpCents ?? p.priceCents;
    }
    return total;
  }

  int get _savingsCents => _bundleMrpCents - _bundleTotalCents;

  void _toggleItem(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _addAllToCart() {
    final cartNotifier = ref.read(cartControllerProvider.notifier);
    cartNotifier.addToCart(widget.mainProduct);
    for (final i in _selectedIndices) {
      cartNotifier.addToCart(widget.bundleProducts[i]);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedIndices.length + 1} items added to cart'),
        backgroundColor: ProductDetailTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bundleProducts.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(_slideAnim),
      child: FadeTransition(
        opacity: _slideAnim,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ProductDetailTheme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cs.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.shopping_basket, size: 18, color: cs.primary),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Frequently Bought Together',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Product items row
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    // Main product
                    _BundleItem(product: widget.mainProduct, isMain: true),
                    ...List.generate(widget.bundleProducts.length, (i) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.add_circle,
                              size: 18,
                              color: cs.primary.withValues(alpha: 0.5),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _toggleItem(i),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: _selectedIndices.contains(i) ? 1.0 : 0.4,
                              child: _BundleItem(
                                product: widget.bundleProducts[i],
                                isSelected: _selectedIndices.contains(i),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Price summary + add all button
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Bundle Price: ',
                                style: textTheme.bodySmall?.copyWith(
                                  color: ProductDetailTheme.textSecondary,
                                ),
                              ),
                              Text(
                                '₹${(_bundleTotalCents / 100).toStringAsFixed(0)}',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: cs.primary,
                                ),
                              ),
                              if (_savingsCents > 0) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '₹${(_bundleMrpCents / 100).toStringAsFixed(0)}',
                                  style: textTheme.bodySmall?.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    color: ProductDetailTheme.textMuted,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (_savingsCents > 0)
                            Text(
                              'You save ₹${(_savingsCents / 100).toStringAsFixed(0)}!',
                              style: textTheme.bodySmall?.copyWith(
                                color: const Color(0xFFF59E0B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _addAllToCart,
                      icon: const Icon(Icons.add_shopping_cart, size: 16),
                      label: const Text('Add All'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BundleItem extends StatelessWidget {
  const _BundleItem({
    required this.product,
    this.isMain = false,
    this.isSelected = true,
  });

  final Product product;
  final bool isMain;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: ProductDetailTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMain
              ? cs.primary.withValues(alpha: 0.4)
              : isSelected
                  ? cs.outlineVariant.withValues(alpha: 0.3)
                  : Colors.transparent,
          width: isMain ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 50,
            width: 50,
            child: product.primaryImageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.primaryImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.image_outlined,
                        size: 24,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                      ),
                    ),
                  )
                : Icon(
                    Icons.image_outlined,
                    size: 24,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                  ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              product.formattedPrice,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
