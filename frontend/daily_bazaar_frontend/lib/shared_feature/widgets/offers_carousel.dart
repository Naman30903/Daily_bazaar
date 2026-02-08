import 'package:flutter/material.dart';
import '../models/home_models.dart';
import '../../core/utils/responsive.dart';

class OffersCarousel extends StatefulWidget {
  const OffersCarousel({super.key, required this.offers, this.onOfferTap});

  final List<OfferBanner> offers;
  final ValueChanged<OfferBanner>? onOfferTap;

  @override
  State<OffersCarousel> createState() => _OffersCarouselState();
}

class _OffersCarouselState extends State<OffersCarousel> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);

    return Column(
      children: [
        SizedBox(
          height: isDesktop
              ? 240
              : isTablet
              ? 200
              : 160,
          child: PageView.builder(
            controller: PageController(
              viewportFraction: isDesktop
                  ? 0.4
                  : isTablet
                  ? 0.6
                  : 0.9,
            ),
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: widget.offers.length,
            itemBuilder: (context, index) {
              final offer = widget.offers[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: InkWell(
                  onTap: () => widget.onOfferTap?.call(offer),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [cs.primaryContainer, cs.secondaryContainer],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            offer.title,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: cs.onPrimaryContainer,
                                ),
                          ),
                          if (offer.subtitle != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              offer.subtitle!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: cs.onPrimaryContainer.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.offers.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? cs.primary
                    : cs.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
