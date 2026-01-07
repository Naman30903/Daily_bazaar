import 'package:flutter/material.dart';
import '../models/home_models.dart';

class CategoryGridSection extends StatelessWidget {
  const CategoryGridSection({
    super.key,
    required this.title,
    required this.categories,
    this.onCategoryTap,
    this.onSeeAllTap,
  });

  final String title;
  final List<CategoryItem> categories;
  final ValueChanged<CategoryItem>? onCategoryTap;
  final VoidCallback? onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(onPressed: onSeeAllTap, child: const Text('See all')),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.68, // Slightly taller to accommodate text
            ),
            itemCount: categories.length > 8 ? 8 : categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final hasImage = category.imageUrl.trim().isNotEmpty;

              return GestureDetector(
                onTap: () => onCategoryTap?.call(category),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Fixed-size image container
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: category.backgroundColor != null
                              ? Color(
                                  category.backgroundColor!,
                                ).withValues(alpha: 0.12)
                              : cs.surfaceContainerHighest.withValues(
                                  alpha: 0.4,
                                ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: hasImage
                              ? Image.network(
                                  category.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _CategoryFallbackIcon(
                                      color: category.backgroundColor != null
                                          ? Color(category.backgroundColor!)
                                          : cs.primary,
                                    );
                                  },
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return Center(
                                      child: SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: cs.primary.withValues(
                                            alpha: 0.6,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : _CategoryFallbackIcon(
                                  color: category.backgroundColor != null
                                      ? Color(category.backgroundColor!)
                                      : cs.primary,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Fixed-height text container for consistency
                    SizedBox(
                      height: 32, // Fixed height for 2 lines of text
                      child: Text(
                        category.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryFallbackIcon extends StatelessWidget {
  const _CategoryFallbackIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        height: 46,
        width: 46,
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
        ),
        child: Icon(Icons.category_outlined, size: 28, color: color),
      ),
    );
  }
}
