import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_bazaar_frontend/shared_feature/config/hive.dart';

/// Account privacy screen with clear, trust-building design.
class AccountPrivacyScreen extends ConsumerStatefulWidget {
  const AccountPrivacyScreen({super.key});

  @override
  ConsumerState<AccountPrivacyScreen> createState() =>
      _AccountPrivacyScreenState();
}

class _AccountPrivacyScreenState extends ConsumerState<AccountPrivacyScreen> {
  bool _marketingEmails = true;
  bool _orderUpdates = true;
  bool _personalizedAds = false;
  bool _dataSharing = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Account & Privacy'),
        backgroundColor: cs.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // Privacy shield hero
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.primary.withValues(alpha: 0.12),
                  cs.tertiary.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: cs.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.primary.withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    size: 32,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Your privacy matters to us',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'We only collect data necessary to deliver\nyour orders and improve your experience',
                  style: textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Communication preferences
          _SectionLabel(title: 'Communication'),
          const SizedBox(height: 10),
          _PrivacyCard(
            children: [
              _ToggleTile(
                icon: Icons.campaign_outlined,
                title: 'Marketing emails',
                subtitle: 'Offers, deals, and new arrivals',
                value: _marketingEmails,
                onChanged: (v) => setState(() => _marketingEmails = v),
              ),
              _CardDivider(),
              _ToggleTile(
                icon: Icons.local_shipping_outlined,
                title: 'Order updates',
                subtitle: 'SMS and push for delivery status',
                value: _orderUpdates,
                onChanged: (v) => setState(() => _orderUpdates = v),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Data preferences
          _SectionLabel(title: 'Data & Personalization'),
          const SizedBox(height: 10),
          _PrivacyCard(
            children: [
              _ToggleTile(
                icon: Icons.ads_click,
                title: 'Personalized recommendations',
                subtitle: 'Suggestions based on your shopping history',
                value: _personalizedAds,
                onChanged: (v) => setState(() => _personalizedAds = v),
              ),
              _CardDivider(),
              _ToggleTile(
                icon: Icons.share_outlined,
                title: 'Share usage data',
                subtitle: 'Anonymous analytics to improve the app',
                value: _dataSharing,
                onChanged: (v) => setState(() => _dataSharing = v),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Data info
          _SectionLabel(title: 'Your Data'),
          const SizedBox(height: 10),
          _PrivacyCard(
            children: [
              _ActionTile(
                icon: Icons.download_outlined,
                title: 'Download my data',
                subtitle: 'Get a copy of all your personal data',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('We\'ll email your data export within 24 hours'),
                    ),
                  );
                },
              ),
              _CardDivider(),
              _ActionTile(
                icon: Icons.visibility_outlined,
                title: 'Privacy policy',
                subtitle: 'How we handle and protect your data',
                onTap: () {},
              ),
              _CardDivider(),
              _ActionTile(
                icon: Icons.description_outlined,
                title: 'Terms of service',
                subtitle: 'Our terms and conditions',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Danger zone
          _SectionLabel(title: 'Account'),
          const SizedBox(height: 10),
          _PrivacyCard(
            children: [
              _ActionTile(
                icon: Icons.logout,
                title: 'Log out',
                subtitle: 'Sign out of your account',
                onTap: () async {
                  final confirmed = await _showConfirmDialog(
                    context,
                    title: 'Log out?',
                    message: 'You\'ll need to sign in again to place orders.',
                    confirmLabel: 'Log out',
                  );
                  if (confirmed && context.mounted) {
                    await TokenStorage.clearToken();
                    if (context.mounted) {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/login', (_) => false);
                    }
                  }
                },
              ),
              _CardDivider(),
              _ActionTile(
                icon: Icons.delete_forever_outlined,
                title: 'Delete account',
                subtitle: 'Permanently remove your account and data',
                isDestructive: true,
                onTap: () async {
                  final confirmed = await _showConfirmDialog(
                    context,
                    title: 'Delete account?',
                    message:
                        'This action is permanent and cannot be undone. All your data, orders, and saved addresses will be deleted.',
                    confirmLabel: 'Delete permanently',
                    isDestructive: true,
                  );
                  if (confirmed && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Account deletion requested. You\'ll receive a confirmation email.'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    bool isDestructive = false,
  }) async {
    final cs = Theme.of(context).colorScheme;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: isDestructive ? cs.error : cs.primary,
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(children: children),
    );
  }
}

class _CardDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Divider(
      height: 1,
      thickness: 1,
      color: cs.outlineVariant.withValues(alpha: 0.3),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 22, color: cs.onSurfaceVariant),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = isDestructive ? cs.error : cs.onSurface;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isDestructive ? cs.error : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: isDestructive
                          ? cs.error.withValues(alpha: 0.7)
                          : cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: isDestructive ? cs.error : cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
