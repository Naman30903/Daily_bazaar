import 'package:daily_bazaar_frontend/routes/route.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/category_model.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/home_models.dart';
import 'package:daily_bazaar_frontend/shared_feature/provider/category_provider.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/category_grid_section.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/home_app_bar.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/offers_carousel.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/search_bar_widget.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/suggested_items_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared_feature/widgets/bottom_nav_bar.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentNavIndex = 0;

  // Mock data - replace with actual API calls
  final List<OfferBanner> _offers = const [
    OfferBanner(
      id: '1',
      imageUrl: '',
      title: '50% OFF',
      subtitle: 'On your first order',
    ),
    OfferBanner(
      id: '2',
      imageUrl: '',
      title: 'Free Delivery',
      subtitle: 'Above ₹299',
    ),
    OfferBanner(
      id: '3',
      imageUrl: '',
      title: 'Festive Sale',
      subtitle: 'Up to 70% off',
    ),
  ];

  final List<SuggestedProduct> _suggestedProducts = const [
    SuggestedProduct(
      id: '1',
      name: 'Fresh Milk 1L',
      imageUrl: '',
      price: 65,
      originalPrice: 75,
      discount: '13% OFF',
    ),
    SuggestedProduct(
      id: '2',
      name: 'Brown Bread',
      imageUrl: '',
      price: 45,
      originalPrice: 55,
    ),
    SuggestedProduct(id: '3', name: 'Farm Eggs (12)', imageUrl: '', price: 80),
    SuggestedProduct(
      id: '4',
      name: 'Paneer 200g',
      imageUrl: '',
      price: 90,
      originalPrice: 110,
    ),
  ];

  // Position ranges for your 3 home sections:
  // 1..8   -> Grocery & Kitchen
  // 9..16  -> Snacks & Drinks
  // 17..24 -> Personal Care
  static const _groceryRange = RootCategoriesParams(
    minPosition: 1,
    maxPosition: 8,
  );
  static const _snacksRange = RootCategoriesParams(
    minPosition: 9,
    maxPosition: 16,
  );
  static const _personalCareRange = RootCategoriesParams(
    minPosition: 17,
    maxPosition: 24,
  );

  List<CategoryItem> _mapToItems(
    List<Category> categories, {
    int? fallbackColor,
  }) {
    return categories
        .map(
          (c) => CategoryItem(
            id: c.id,
            name: c.name,
            imageUrl: c.imageUrl ?? '',
            backgroundColor: fallbackColor,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final groceryAsync = ref.watch(
      filteredRootCategoriesProvider(_groceryRange),
    );
    final snacksAsync = ref.watch(filteredRootCategoriesProvider(_snacksRange));
    final personalAsync = ref.watch(
      filteredRootCategoriesProvider(_personalCareRange),
    );

    return Scaffold(
      appBar: HomeAppBar(
        deliveryAddress: 'Home - Sector 62, Noida',
        onProfileTap: () => Navigator.of(context).pushNamed(Routes.profile),
        onAddressTap: () {
          // TODO: show address selection
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SearchBarWidget(
              onTap: () {
                // TODO: navigate to search page
              },
            ),
            const SizedBox(height: 8),
            OffersCarousel(
              offers: _offers,
              onOfferTap: (offer) {
                // TODO: handle offer tap
              },
            ),
            const SizedBox(height: 16),
            SuggestedItemsSection(
              products: _suggestedProducts,
              onProductTap: (product) {
                // TODO: navigate to product detail
              },
              onAddToCart: (product) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} added to cart'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Grocery & Kitchen (positions 1..8)
            groceryAsync.when(
              data: (cats) => CategoryGridSection(
                title: 'Grocery & Kitchen',
                categories: _mapToItems(cats, fallbackColor: 0xFFE3F2FD),
                onCategoryTap: (categoryItem) {
                  // Find the original Category from the list
                  final category = cats.firstWhere(
                    (c) => c.id == categoryItem.id,
                  );
                  Navigator.of(
                    context,
                  ).pushNamed(Routes.categoryBrowse, arguments: category);
                },
              ),
              loading: () =>
                  const _CategorySectionSkeleton(title: 'Grocery & Kitchen'),
              error: (e, _) => _CategorySectionError(
                title: 'Grocery & Kitchen',
                message: e.toString(),
                onRetry: () => ref.invalidate(
                  filteredRootCategoriesProvider(_groceryRange),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Snacks & Drinks (positions 9..16)
            snacksAsync.when(
              data: (cats) => CategoryGridSection(
                title: 'Snacks & Drinks',
                categories: _mapToItems(cats, fallbackColor: 0xFFFFE0B2),
                onCategoryTap: (category) {
                  // TODO: navigate to category products / subcategories
                },
              ),
              loading: () =>
                  const _CategorySectionSkeleton(title: 'Snacks & Drinks'),
              error: (e, _) => _CategorySectionError(
                title: 'Snacks & Drinks',
                message: e.toString(),
                onRetry: () => ref.invalidate(
                  filteredRootCategoriesProvider(_snacksRange),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Personal Care (positions 17..24)
            personalAsync.when(
              data: (cats) => CategoryGridSection(
                title: 'Personal Care',
                categories: _mapToItems(cats, fallbackColor: 0xFFE1F5FE),
                onCategoryTap: (category) {
                  // TODO: navigate to category products / subcategories
                },
              ),
              loading: () =>
                  const _CategorySectionSkeleton(title: 'Personal Care'),
              error: (e, _) => _CategorySectionError(
                title: 'Personal Care',
                message: e.toString(),
                onRetry: () => ref.invalidate(
                  filteredRootCategoriesProvider(_personalCareRange),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
          // TODO: handle navigation to other tabs
          if (index == 1) {
            // Navigate to categories page
          } else if (index == 2) {
            // Navigate to trending page
          }
        },
      ),
    );
  }
}

class _CategorySectionSkeleton extends StatelessWidget {
  const _CategorySectionSkeleton({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: 8,
            itemBuilder: (_, __) => Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 10,
                  width: 52,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CategorySectionError extends StatelessWidget {
  const _CategorySectionError({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: cs.error),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      ),
    );
  }
}
