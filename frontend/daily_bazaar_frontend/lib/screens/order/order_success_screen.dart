import 'dart:math';
import 'package:flutter/material.dart';

/// Celebratory order success screen with emotional design.
class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.amountDisplay,
  });

  final String orderId;
  final String amountDisplay;

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _checkController;
  late final AnimationController _fadeController;
  late final AnimationController _confettiController;
  late final Animation<double> _checkScale;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _checkScale = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Stagger the animations
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _checkController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _confettiController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _fadeController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: cs.surface,
        body: Stack(
          children: [
            // Confetti particles
            AnimatedBuilder(
              animation: _confettiController,
              builder: (context, _) => CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _ConfettiPainter(
                  progress: _confettiController.value,
                  colors: [
                    cs.primary,
                    cs.tertiary,
                    cs.secondary,
                    const Color(0xFFFBBF24),
                    const Color(0xFFFB7185),
                    const Color(0xFF38BDF8),
                  ],
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),

                      // Animated check circle
                      ScaleTransition(
                        scale: _checkScale,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                cs.primary,
                                cs.primary.withValues(alpha: 0.7),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: cs.primary.withValues(alpha: 0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Text content with fade
                      FadeTransition(
                        opacity: _fadeIn,
                        child: Column(
                          children: [
                            Text(
                              'Order Placed!',
                              style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your order is confirmed and on its way',
                              style: textTheme.bodyLarge?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 28),

                            // Order details card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      cs.outlineVariant.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Order ID',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                      Text(
                                        '#${widget.orderId.length > 8 ? widget.orderId.substring(0, 8).toUpperCase() : widget.orderId.toUpperCase()}',
                                        style: textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    child: Divider(
                                      height: 1,
                                      color: cs.outlineVariant
                                          .withValues(alpha: 0.2),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Amount Paid',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                      Text(
                                        widget.amountDisplay,
                                        style:
                                            textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: cs.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Delivery estimate
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: cs.primary.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.local_shipping_outlined,
                                      color: cs.primary, size: 22),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Estimated delivery in 15-20 minutes',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: cs.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 2),

                      // Bottom buttons
                      FadeTransition(
                        opacity: _fadeIn,
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: FilledButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamedAndRemoveUntil('/home', (_) => false);
                                },
                                style: FilledButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'Continue Shopping',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamedAndRemoveUntil('/home', (_) => false);
                                  Navigator.of(context)
                                      .pushNamed('/order-history');
                                },
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'View Order History',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Confetti painter for celebratory effect.
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress, required this.colors});

  final double progress;
  final List<Color> colors;
  final _rng = Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint();
    const particleCount = 60;

    for (var i = 0; i < particleCount; i++) {
      final seed = _rng.nextDouble();
      final colorIndex = i % colors.length;
      paint.color = colors[colorIndex].withValues(
        alpha: (1.0 - progress * 0.6).clamp(0.0, 1.0),
      );

      final startX = size.width * _rng.nextDouble();
      final startY = -20.0;
      final endX = startX + (_rng.nextDouble() - 0.5) * 200;
      final endY = size.height * (0.3 + _rng.nextDouble() * 0.7);

      final x = startX + (endX - startX) * progress;
      final y = startY + (endY - startY) * progress;

      final w = 4.0 + _rng.nextDouble() * 6;
      final h = 3.0 + _rng.nextDouble() * 4;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * (2 + seed * 6));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: h),
          const Radius.circular(1.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
