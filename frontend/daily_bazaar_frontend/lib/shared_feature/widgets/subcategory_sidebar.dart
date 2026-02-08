import 'package:flutter/material.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/category_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SubcategorySidebar extends StatelessWidget {
  const SubcategorySidebar({
    super.key,
    required this.subcategories,
    required this.selectedId,
    required this.isLoading,
    this.error,
    required this.onSubcategoryTap,
    this.direction = Axis.vertical,
  });

  final List<Category> subcategories;
  final String? selectedId;
  final bool isLoading;
  final String? error;
  final ValueChanged<Category> onSubcategoryTap;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: cs.error, size: 32),
              const SizedBox(height: 8),
              Text(
                'Failed to load',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (isLoading && subcategories.isEmpty) {
      return const _SidebarSkeleton();
    }

    if (subcategories.isEmpty) {
      return Center(
        child: Text(
          'No subcategories',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      );
    }

    return Container(
      color: cs.surfaceContainerLowest,
      child: ListView.builder(
        scrollDirection: direction,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        itemCount: subcategories.length,
        itemBuilder: (context, index) {
          final subcategory = subcategories[index];
          final isSelected = subcategory.id == selectedId;

          return _SubcategoryItem(
            subcategory: subcategory,
            isSelected: isSelected,
            onTap: () => onSubcategoryTap(subcategory),
          );
        },
      ),
    );
  }
}

class _SubcategoryItem extends StatelessWidget {
  const _SubcategoryItem({
    required this.subcategory,
    required this.isSelected,
    required this.onTap,
  });

  final Category subcategory;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? cs.surface : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? cs.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category image
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? cs.primaryContainer.withValues(alpha: 0.4)
                    : cs.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? cs.primary.withValues(alpha: 0.3)
                      : cs.outlineVariant.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child:
                    subcategory.imageUrl != null &&
                        subcategory.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: subcategory.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cs.primary,
                            ),
                          ),
                        ),
                        errorWidget: (_, _, _) => Icon(
                          Icons.category_outlined,
                          color: isSelected ? cs.primary : cs.onSurfaceVariant,
                          size: 24,
                        ),
                      )
                    : Icon(
                        Icons.category_outlined,
                        color: isSelected ? cs.primary : cs.onSurfaceVariant,
                        size: 24,
                      ),
              ),
            ),
            const SizedBox(height: 6),
            // Category name
            Text(
              subcategory.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? cs.primary : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarSkeleton extends StatelessWidget {
  const _SidebarSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 8,
      itemBuilder: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 48,
              height: 10,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
