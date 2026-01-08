import 'package:flutter/material.dart';

/// Generic bill row item widget
class BillRowItem extends StatelessWidget {
  const BillRowItem({
    super.key,
    required this.label,
    required this.value,
    this.badge,
    this.sublabel,
    this.sublabelColor,
    this.isBold = false,
  });

  final String label;
  final String value;
  final String? badge;
  final String? sublabel;
  final Color? sublabelColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Label with optional badge
              Row(
                children: [
                  Icon(
                    _getIconForLabel(label),
                    size: 16,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                      color: cs.onSurface,
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badge!,
                        style: textTheme.labelSmall?.copyWith(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Value
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),

          // Optional sublabel
          if (sublabel != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                sublabel!,
                style: textTheme.bodySmall?.copyWith(
                  color: sublabelColor ?? cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    if (label.contains('Items total')) return Icons.receipt_outlined;
    if (label.contains('Handling')) return Icons.local_shipping_outlined;
    if (label.contains('surge')) return Icons.trending_up_outlined;
    return Icons.info_outline;
  }
}
