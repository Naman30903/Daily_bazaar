import 'package:daily_bazaar_frontend/shared_feature/models/checkout_models.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/checkout/instruction_toggle_tile.dart';
import 'package:flutter/material.dart';

/// Delivery instructions section
class DeliveryInstructionsSection extends StatelessWidget {
  const DeliveryInstructionsSection({
    super.key,
    required this.instructions,
    required this.onToggle,
  });

  final List<DeliveryInstruction> instructions;
  final Function(DeliveryInstructionType) onToggle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section heading
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Delivery instructions',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
          ),

          // Grid of instruction tiles
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: instructions.length,
            itemBuilder: (context, index) {
              final instruction = instructions[index];
              return InstructionToggleTile(
                instruction: instruction,
                onToggle: () => onToggle(instruction.type),
              );
            },
          ),
        ],
      ),
    );
  }
}
