import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    required this.deliveryAddress,
    this.onProfileTap,
    this.onAddressTap,
  });

  final String deliveryAddress;
  final VoidCallback? onProfileTap;
  final VoidCallback? onAddressTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: cs.surface,
      elevation: 0,
      titleSpacing: 16,
      automaticallyImplyLeading: false,
      title: InkWell(
        onTap: onAddressTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Icon(Icons.location_on_outlined, color: cs.primary, size: 20),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deliver to',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    deliveryAddress,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 20, color: cs.onSurface),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: cs.primaryContainer,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: onProfileTap,
              icon: Icon(Icons.person_outline, size: 20, color: cs.primary),
            ),
          ),
        ),
      ],
    );
  }
}
