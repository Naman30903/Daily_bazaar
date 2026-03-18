import 'dart:async';
import 'package:flutter/material.dart';
import '../models/home_models.dart';
import '../../core/utils/responsive.dart';

// Gradient presets — muted, sophisticated tones on dark navy
const _bannerGradients = <List<Color>>[
  [Color(0xFF064E3B), Color(0xFF34D399)], // emerald
  [Color(0xFF1E3A5F), Color(0xFF60A5FA)], // soft blue
  [Color(0xFF78350F), Color(0xFFF59E0B)], // amber
  [Color(0xFF4C1D95), Color(0xFFA78BFA)], // soft purple
  [Color(0xFF7C2D12), Color(0xFFFB923C)], // warm orange
];

const _bannerIcons = <IconData>[
  Icons.local_offer,
  Icons.delivery_dining,
  Icons.celebration,
  Icons.card_giftcard,
  Icons.savings,
];

class OffersCarousel extends StatefulWidget {
  const OffersCarousel({super.key, required this.offers, this.onOfferTap});

  final List<OfferBanner> offers;
  final ValueChanged<OfferBanner>? onOfferTap;

  @override
  State<OffersCarousel> createState() => _OffersCarouselState();
}

class _OffersCarouselState extends State<OffersCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || widget.offers.isEmpty) return;
      final next = (_currentPage + 1) % widget.offers.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

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
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: widget.offers.length,
            itemBuilder: (context, index) {
              final offer = widget.offers[index];
              final gradient = _bannerGradients[index % _bannerGradients.length];
              final icon = _bannerIcons[index % _bannerIcons.length];
              return AnimatedScale(
                scale: _currentPage == index ? 1.0 : 0.92,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: InkWell(
                    onTap: () => widget.onOfferTap?.call(offer),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: gradient.last.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Background icon
                          Positioned(
                            right: -10,
                            bottom: -10,
                            child: Icon(
                              icon,
                              size: 100,
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Limited Time',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white.withValues(alpha: 0.9),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  offer.title,
                                  style: Theme.of(context).textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                ),
                                if (offer.subtitle != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    offer.subtitle!,
                                    style: Theme.of(context).textTheme.bodyMedium
                                        ?.copyWith(
                                          color: Colors.white.withValues(alpha: 0.85),
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
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
              margin: const EdgeInsets.symmetric(horizontal: 3),
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
