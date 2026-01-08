import 'package:flutter/material.dart';

/// Donation section widget
class DonationSection extends StatelessWidget {
  const DonationSection({
    super.key,
    required this.title,
    required this.description,
    this.donationAmount,
    required this.defaultAmount,
    required this.onAddDonation,
    this.onRemoveDonation,
  });

  final String title;
  final String description;
  final int? donationAmount;
  final int defaultAmount;
  final VoidCallback onAddDonation;
  final VoidCallback? onRemoveDonation;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasDonation = donationAmount != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade900.withValues(alpha: 0.4),
            Colors.purple.shade900.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with info icon
          Row(
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.info_outline,
                size: 18,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Description
          Text(
            description,
            style: textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          // Image placeholder (children photo from screenshot)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 100,
              width: double.infinity,
              color: cs.surfaceContainerHigh,
              child: Center(
                child: Icon(
                  Icons.favorite_border,
                  size: 40,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Donation amount and Add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Donation amount',
                style: textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface,
                ),
              ),

              Row(
                children: [
                  if (hasDonation)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '₹${donationAmount! ~/ 100}',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: hasDonation ? onRemoveDonation : onAddDonation,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: hasDonation ? cs.error : cs.primary,
                        width: 1.5,
                        style: hasDonation
                            ? BorderStyle.solid
                            : BorderStyle.solid,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      hasDonation ? 'Remove' : 'Add',
                      style: TextStyle(
                        color: hasDonation ? cs.error : cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
