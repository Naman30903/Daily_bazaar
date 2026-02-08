import 'package:daily_bazaar_frontend/shared_feature/models/checkout_models.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/checkout/bill_row_item.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/checkout/savings_banner.dart';
import 'package:flutter/material.dart';

/// Bill details section
class BillDetailsSection extends StatelessWidget {
  const BillDetailsSection({super.key, required this.billDetails});

  final BillDetails billDetails;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section heading
          Text(
            'Bill details',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),

          const SizedBox(height: 16),

          // Items total
          BillRowItem(
            label: 'Items total',
            value: billDetails.formattedItemsTotal,
            badge: billDetails.savedAmountCents > 0
                ? 'Saved ${billDetails.formattedSavedAmount}'
                : null,
          ),

          // Handling charge
          BillRowItem(
            label: 'Handling charge',
            value: billDetails.formattedHandlingCharge,
          ),

          const Divider(height: 24),

          // Grand total
          BillRowItem(
            label: 'Grand total',
            value: billDetails.formattedGrandTotal,
            isBold: true,
          ),

          const SizedBox(height: 16),

          // Savings banner
          if (billDetails.savedAmountCents > 0)
            SavingsBanner(savingsAmount: billDetails.formattedSavedAmount),
        ],
      ),
    );
  }
}
