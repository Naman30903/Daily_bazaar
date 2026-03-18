import 'package:flutter/material.dart';

/// Shows progress toward free shipping threshold.
/// Motivates users to add more items to reach free shipping.
class FreeShippingBar extends StatelessWidget {
  const FreeShippingBar({
    super.key,
    required this.currentAmountCents,
    this.thresholdCents = 50000, // ₹500
  });

  final int currentAmountCents;
  final int thresholdCents;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final progress = (currentAmountCents / thresholdCents).clamp(0.0, 1.0);
    final reached = currentAmountCents >= thresholdCents;
    final remainingRupees = ((thresholdCents - currentAmountCents) / 100).ceil();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: reached
            ? cs.primary.withValues(alpha: 0.1)
            : cs.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: reached
              ? cs.primary.withValues(alpha: 0.3)
              : cs.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                reached ? Icons.local_shipping : Icons.local_shipping_outlined,
                size: 18,
                color: reached ? cs.primary : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  reached
                      ? 'You got FREE delivery!'
                      : 'Add ₹$remainingRupees more for FREE delivery',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: reached ? cs.primary : cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: cs.outlineVariant.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation(
                    reached ? cs.primary : const Color(0xFFF59E0B),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
