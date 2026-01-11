import 'package:daily_bazaar_frontend/screens/product_detail_screen.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/product_grid.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/subcategory_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/category_model.dart';
import 'package:daily_bazaar_frontend/shared_feature/provider/category_browse_provider.dart';

class CategoryBrowsePage extends ConsumerWidget {
  const CategoryBrowsePage({super.key, required this.parentCategory});

  final Category parentCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final browseState = ref.watch(
      categoryBrowseControllerProvider(parentCategory.id),
    );
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(parentCategory.name),
        backgroundColor: cs.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Navigate to search
            },
          ),
        ],
      ),
      body: browseState.when(
        data: (state) => Row(
          children: [
            // Left Sidebar (20-25% width)
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.22,
              child: SubcategorySidebar(
                subcategories: state.subcategories,
                selectedId: state.selectedSubcategoryId,
                isLoading: state.isLoadingSubcategories,
                error: state.subcategoriesError,
                onSubcategoryTap: (subcategory) {
                  ref
                      .read(
                        categoryBrowseControllerProvider(
                          parentCategory.id,
                        ).notifier,
                      )
                      .selectSubcategory(subcategory.id);
                },
              ),
            ),
            // Divider
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: cs.outlineVariant.withValues(alpha: 0.3),
            ),
            // Right Panel (75-80% width)
            Expanded(
              child: ProductGrid(
                products: state.products,
                isLoading: state.isLoadingProducts,
                error: state.productsError,
                hasMore: state.hasMoreProducts,
                onLoadMore: () {
                  ref
                      .read(
                        categoryBrowseControllerProvider(
                          parentCategory.id,
                        ).notifier,
                      )
                      .loadMoreProducts();
                },
                onRefresh: () async {
                  await ref
                      .read(
                        categoryBrowseControllerProvider(
                          parentCategory.id,
                        ).notifier,
                      )
                      .refreshProducts();
                },
                onAddToCart: (product) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} added to cart'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                onProductTap: (product) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(
                        product: product,
                        similarProducts: state.products
                            .where((p) => p.id != product.id)
                            .take(5)
                            .toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        loading: () => const _LoadingSkeleton(),
        error: (e, _) => _ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(
            categoryBrowseControllerProvider(parentCategory.id),
          ),
        ),
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Sidebar skeleton
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.22,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: 8,
            itemBuilder: (_, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
          ),
        ),
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: cs.outlineVariant.withValues(alpha: 0.3),
        ),
        // Products skeleton
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: 6,
            itemBuilder: (_, _) => Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: cs.error),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
