import 'package:daily_bazaar_frontend/shared_feature/models/checkout_models.dart';
import 'package:flutter/material.dart';

/// Toggle tile for delivery instructions
class InstructionToggleTile extends StatelessWidget {
  const InstructionToggleTile({
    super.key,
    required this.instruction,
    required this.onToggle,
  });

  final DeliveryInstruction instruction;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: instruction.enabled
          ? cs.primaryContainer.withValues(alpha: 0.3)
          : cs.surfaceContainerHighest.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon
                  Icon(
                    _getIconForType(instruction.type),
                    size: 24,
                    color: instruction.enabled
                        ? cs.primary
                        : cs.onSurfaceVariant,
                  ),

                  // Checkbox
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: instruction.enabled
                          ? cs.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: instruction.enabled
                            ? cs.primary
                            : cs.outlineVariant,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: instruction.enabled
                        ? Icon(
                            Icons.check,
                            size: 14,
                            color: cs.onPrimary,
                          )
                        : null,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Label
              Text(
                instruction.label,
                style: textTheme.bodySmall?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(DeliveryInstructionType type) {
    switch (type) {
      case DeliveryInstructionType.pressHereAndHold:
        return Icons.mic_outlined;
      case DeliveryInstructionType.avoidCalling:
        return Icons.phone_disabled_outlined;
      case DeliveryInstructionType.dontRingBell:
        return Icons.notifications_off_outlined;
    }
  }
}
