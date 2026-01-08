import 'package:flutter/material.dart';

/// Reusable quantity stepper widget for cart items
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.minQuantity = 1,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final int minQuantity;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final canDecrement = quantity > minQuantity;

    return Container(
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: canDecrement ? onDecrement : null,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(8),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Icon(
                  Icons.remove,
                  size: 18,
                  color: canDecrement
                      ? cs.onPrimary
                      : cs.onPrimary.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),

          // Quantity display
          Container(
            constraints: const BoxConstraints(minWidth: 32),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              quantity.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),

          // Increment button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onIncrement,
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(8),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Icon(
                  Icons.add,
                  size: 18,
                  color: cs.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
