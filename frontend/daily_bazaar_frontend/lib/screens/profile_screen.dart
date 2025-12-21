import 'package:daily_bazaar_frontend/shared_feature/config/hive.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/snackbar.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _ProfileHeader(name: null, phone: null),
          const SizedBox(height: 14),

          // Quick actions row (layout only; hook actions later)
          Row(
            children: const [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Your orders',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Wallet',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.support_agent_outlined,
                  label: 'Need help?',
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _SectionTitle(title: 'Your information'),
          const SizedBox(height: 10),
          _SettingsCard(
            children: const [
              _SettingsTile(
                icon: Icons.location_on_outlined,
                title: 'Address book',
              ),
              _Divider(),
              _SettingsTile(
                icon: Icons.favorite_border,
                title: 'Your wishlist',
              ),
              _Divider(),
            ],
          ),

          const SizedBox(height: 18),

          _SectionTitle(title: 'Other information'),
          const SizedBox(height: 10),
          _SettingsCard(
            children: [
              const _SettingsTile(
                icon: Icons.share_outlined,
                title: 'Share the app',
              ),
              const _Divider(),
              const _SettingsTile(icon: Icons.info_outline, title: 'About us'),
              const _Divider(),
              const _SettingsTile(
                icon: Icons.lock_outline,
                title: 'Account privacy',
              ),
              const _Divider(),
              const _SettingsTile(
                icon: Icons.notifications_none_outlined,
                title: 'Notification preferences',
              ),
              const _Divider(),
              _SettingsTile(
                icon: Icons.logout,
                title: 'Log out',
                isDestructive: true,
                onTap: () async {
                  await TokenStorage.clearToken();
                  if (context.mounted) {
                    showAppSnackBar(context, 'Logged out');
                    Navigator.of(
                      context,
                    ).pop(); // go back (or route to login later)
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 18),
          Center(
            child: Text(
              'daily bazaar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: cs.onSurfaceVariant.withValues(alpha: 0.35),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'v1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant.withValues(alpha: 0.35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({this.name, this.phone, this.dobText});

  final String? name;
  final String? phone;
  final String? dobText;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: cs.primaryContainer,
            child: Icon(Icons.person_outline, size: 34, color: cs.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (name?.trim().isNotEmpty ?? false) ? name! : 'Your name',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    _MetaChip(
                      icon: Icons.phone_outlined,
                      label: (phone?.trim().isNotEmpty ?? false)
                          ? phone!
                          : 'Phone',
                    ),
                    _MetaChip(
                      icon: Icons.cake_outlined,
                      label: (dobText?.trim().isNotEmpty ?? false)
                          ? dobText!
                          : 'DOB',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 92,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: cs.onSurface, size: 26),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: cs.onSurface,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final titleColor = isDestructive ? cs.error : cs.onSurface;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: isDestructive ? cs.error : cs.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: titleColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Divider(
      height: 1,
      thickness: 1,
      color: cs.outlineVariant.withValues(alpha: 0.35),
    );
  }
}
