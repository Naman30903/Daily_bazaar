import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../provider/cart_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FlashDealsSection extends ConsumerStatefulWidget {
  const FlashDealsSection({super.key, required this.products});

  final List<Product> products;

  @override
  ConsumerState<FlashDealsSection> createState() => _FlashDealsSectionState();
}

class _FlashDealsSectionState extends ConsumerState<FlashDealsSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late Duration _timeLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Flash deal ends at midnight
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    _timeLeft = midnight.difference(now);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _timeLeft -= const Duration(seconds: 1);
        if (_timeLeft.isNegative) _timeLeft = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with countdown
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + _pulseController.value * 0.15,
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.flash_on, color: Color(0xFFEF4444), size: 20),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Flash Deals',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              // Countdown timer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, size: 14, color: const Color(0xFFEF4444)),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(_timeLeft),
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFEF4444),
                        fontFamily: 'monospace',
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Product cards
        SizedBox(
          height: 220,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: widget.products.length,
            itemBuilder: (context, index) {
              return _FlashDealCard(
                product: widget.products[index],
                index: index,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FlashDealCard extends ConsumerStatefulWidget {
  const _FlashDealCard({required this.product, required this.index});

  final Product product;
  final int index;

  @override
  ConsumerState<_FlashDealCard> createState() => _FlashDealCardState();
}

class _FlashDealCardState extends ConsumerState<_FlashDealCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final product = widget.product;
    final cartState = ref.watch(cartControllerProvider);
    final inCart = cartState.contains(product.id);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnim.value,
          child: Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(
            '/product-detail',
            arguments: {'product': product, 'similarProducts': <Product>[]},
          );
        },
        child: Container(
          width: 155,
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFEF4444).withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image + discount badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: SizedBox(
                      height: 110,
                      width: double.infinity,
                      child: product.primaryImageUrl != null
                          ? Image.network(
                              product.primaryImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _placeholder(cs),
                            )
                          : _placeholder(cs),
                    ),
                  ),
                  if (product.discountPercent != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${product.discountPercent}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (product.weight != null)
                      Text(
                        product.weight!,
                        style: textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          product.formattedPrice,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.primary,
                          ),
                        ),
                        if (product.formattedMrp != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            product.formattedMrp!,
                            style: textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                              fontSize: 11,
                            ),
                          ),
                        ],
                        const Spacer(),
                        _AddButton(
                          inCart: inCart,
                          onTap: () {
                            ref.read(cartControllerProvider.notifier).addToCart(product);
                          },
                        ),
                      ],
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

  Widget _placeholder(ColorScheme cs) {
    return Container(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Center(
        child: Icon(Icons.image_outlined, size: 32, color: cs.onSurfaceVariant.withValues(alpha: 0.3)),
      ),
    );
  }
}

class _AddButton extends StatefulWidget {
  const _AddButton({required this.inCart, required this.onTap});
  final bool inCart;
  final VoidCallback onTap;

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> with SingleTickerProviderStateMixin {
  late final AnimationController _bounceCtrl;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        _bounceCtrl.forward().then((_) => _bounceCtrl.reverse());
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _bounceCtrl,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + _bounceCtrl.value * 0.2,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: widget.inCart ? cs.primary : cs.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.inCart ? 'Added' : 'ADD',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: widget.inCart ? cs.onPrimary : cs.primary,
            ),
          ),
        ),
      ),
    );
  }
}
