import 'package:flutter/material.dart';

/// About Us screen with warm, human-centered emotional design.
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // Immersive header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: cs.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      cs.primary.withValues(alpha: 0.15),
                      cs.surface,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              cs.primary,
                              cs.primary.withValues(alpha: 0.6),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: cs.primary.withValues(alpha: 0.25),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.storefront_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Daily Bazaar',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fresh. Fast. For you.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Mission statement
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        icon: Icons.favorite_rounded,
                        iconColor: const Color(0xFFFB7185),
                        title: 'Our Mission',
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'We believe everyone deserves access to fresh, quality groceries delivered right to their doorstep. Daily Bazaar was born from a simple idea — make daily shopping effortless, so you can spend more time on what truly matters.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Values
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        icon: Icons.auto_awesome,
                        iconColor: const Color(0xFFFBBF24),
                        title: 'What We Stand For',
                      ),
                      const SizedBox(height: 16),
                      _ValueTile(
                        emoji: '🌿',
                        title: 'Freshness First',
                        description:
                            'Every product is sourced fresh and quality-checked before it reaches you.',
                      ),
                      const SizedBox(height: 14),
                      _ValueTile(
                        emoji: '⚡',
                        title: 'Lightning Delivery',
                        description:
                            'From order to doorstep in minutes, not hours. Because your time is precious.',
                      ),
                      const SizedBox(height: 14),
                      _ValueTile(
                        emoji: '💚',
                        title: 'Community Care',
                        description:
                            'We partner with local vendors and support community-driven commerce.',
                      ),
                      const SizedBox(height: 14),
                      _ValueTile(
                        emoji: '🤝',
                        title: 'Fair Pricing',
                        description:
                            'Transparent prices with no hidden costs. What you see is what you pay.',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Story
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        icon: Icons.menu_book_rounded,
                        iconColor: const Color(0xFF38BDF8),
                        title: 'Our Story',
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Started in 2024 with a vision to transform how India shops for daily essentials. We noticed that while technology was changing everything around us, the simple act of buying groceries remained cumbersome and time-consuming.\n\nToday, we serve thousands of happy customers, delivering everything from fresh vegetables to pantry staples with a promise of quality and speed.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Contact
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        icon: Icons.mail_outline_rounded,
                        iconColor: cs.primary,
                        title: 'Get in Touch',
                      ),
                      const SizedBox(height: 12),
                      _ContactRow(
                        icon: Icons.email_outlined,
                        text: 'support@dailybazaar.com',
                      ),
                      const SizedBox(height: 10),
                      _ContactRow(
                        icon: Icons.language,
                        text: 'www.dailybazaar.com',
                      ),
                      const SizedBox(height: 10),
                      _ContactRow(
                        icon: Icons.location_on_outlined,
                        text: 'India',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Made with 💚 in India',
                    style: textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    'v1.0.0',
                    style: textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
  });

  final IconData icon;
  final Color iconColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: iconColor),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _ValueTile extends StatelessWidget {
  const _ValueTile({
    required this.emoji,
    required this.title,
    required this.description,
  });

  final String emoji;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 18)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
