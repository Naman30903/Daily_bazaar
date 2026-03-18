import 'package:daily_bazaar_frontend/routes/route.dart';
import '../core/utils/responsive.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/category_model.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/home_models.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/product_model.dart';
import 'package:daily_bazaar_frontend/shared_feature/provider/category_provider.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/category_grid_section.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/flash_deals_section.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/free_shipping_bar.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/home_app_bar.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/offers_carousel.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/search_bar_widget.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/staggered_fade_slide.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/suggested_items_section.dart';
import 'package:daily_bazaar_frontend/shared_feature/config/config.dart';
import 'package:daily_bazaar_frontend/shared_feature/helper/api_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_bazaar_frontend/shared_feature/provider/cart_provider.dart';
import 'package:daily_bazaar_frontend/shared_feature/provider/user_provider.dart';
import '../../shared_feature/widgets/bottom_nav_bar.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentNavIndex = 0;
  List<Product> _flashDealProducts = [];
  bool _flashDealsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFlashDeals();
  }

  Future<void> _loadFlashDeals() async {
    try {
      final client = ApiClient(baseUrl: AppEnvironment.apiBaseUrl);
      final resp = await client.getJsonList('/api/products?limit=10');
      if (!mounted) return;
      setState(() {
        _flashDealProducts = resp.map((e) => Product.fromJson(e)).toList();
        _flashDealsLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _flashDealsLoading = false);
    }
  }

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
      subtitle: 'Orders above ₹500',
    ),
    OfferBanner(
      id: '3',
      imageUrl: '',
      title: 'Festive Sale',
      subtitle: 'Up to 70% off on all items',
    ),
    OfferBanner(
      id: '4',
      imageUrl: '',
      title: 'New Arrivals',
      subtitle: 'Fresh stock every day',
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
    final cartState = ref.watch(cartControllerProvider);
    final userAsync = ref.watch(userControllerProvider);

    String deliveryAddressText = 'Set delivery address';
    userAsync.when(
      data: (profile) {
        final addrs = profile.addresses;
        if (addrs.isNotEmpty) {
          final addr = addrs.firstWhere(
            (a) => a.isDefault,
            orElse: () => addrs.first,
          );
          final label = addr.label ?? 'Home';
          deliveryAddressText = '$label - ${addr.formattedAddress}';
        } else {
          deliveryAddressText = 'Add delivery address';
        }
      },
      loading: () => deliveryAddressText = 'Loading address...',
      error: (_, _) => deliveryAddressText = 'Set delivery address',
    );

    return Scaffold(
      appBar: HomeAppBar(
        deliveryAddress: deliveryAddressText,
        onProfileTap: () => Navigator.of(context).pushNamed(Routes.profile),
        onAddressTap: () {
          Navigator.of(context).pushNamed(Routes.addresses);
        },
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.isDesktop(context) ? 1000 : 800,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                StaggeredFadeSlide(
                  index: 0,
                  child: SearchBarWidget(
                    onTap: () {
                      Navigator.of(context).pushNamed(Routes.search);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                StaggeredFadeSlide(
                  index: 1,
                  child: OffersCarousel(
                    offers: _offers,
                    onOfferTap: (offer) {},
                  ),
                ),
                const SizedBox(height: 12),

                // Free shipping progress bar (only when cart has items)
                if (!cartState.isEmpty)
                  StaggeredFadeSlide(
                    index: 0,
                    child: FreeShippingBar(
                      currentAmountCents: cartState.items.fold(
                        0,
                        (sum, item) => sum + item.totalPriceCents,
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                // Flash Deals
                if (!_flashDealsLoading && _flashDealProducts.isNotEmpty)
                  StaggeredFadeSlide(
                    index: 2,
                    child: FlashDealsSection(products: _flashDealProducts),
                  ),

                const SizedBox(height: 16),
                StaggeredFadeSlide(
                  index: 3,
                  child: SuggestedItemsSection(
                    products: _suggestedProducts,
                    onProductTap: (product) {},
                    onAddToCart: (product) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} added to cart'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Grocery & Kitchen (positions 1..8)
                StaggeredFadeSlide(
                  index: 4,
                  child: groceryAsync.when(
                    data: (cats) => CategoryGridSection(
                      title: 'Grocery & Kitchen',
                      categories: _mapToItems(cats, fallbackColor: 0xFFE3F2FD),
                      onCategoryTap: (categoryItem) {
                        final category = cats.firstWhere(
                          (c) => c.id == categoryItem.id,
                        );
                        Navigator.of(
                          context,
                        ).pushNamed(Routes.categoryBrowse, arguments: category);
                      },
                    ),
                    loading: () => const _CategorySectionSkeleton(
                      title: 'Grocery & Kitchen',
                    ),
                    error: (e, _) => _CategorySectionError(
                      title: 'Grocery & Kitchen',
                      message: e.toString(),
                      onRetry: () => ref.invalidate(
                        filteredRootCategoriesProvider(_groceryRange),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Snacks & Drinks (positions 9..16)
                StaggeredFadeSlide(
                  index: 5,
                  child: snacksAsync.when(
                    data: (cats) => CategoryGridSection(
                      title: 'Snacks & Drinks',
                      categories: _mapToItems(cats, fallbackColor: 0xFFFFE0B2),
                      onCategoryTap: (categoryItem) {
                        final category = cats.firstWhere(
                          (c) => c.id == categoryItem.id,
                        );
                        Navigator.of(
                          context,
                        ).pushNamed(Routes.categoryBrowse, arguments: category);
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
                ),

                const SizedBox(height: 16),

                // Personal Care (positions 17..24)
                StaggeredFadeSlide(
                  index: 6,
                  child: personalAsync.when(
                    data: (cats) => CategoryGridSection(
                      title: 'Personal Care',
                      categories: _mapToItems(cats, fallbackColor: 0xFFE1F5FE),
                      onCategoryTap: (categoryItem) {
                        final category = cats.firstWhere(
                          (c) => c.id == categoryItem.id,
                        );
                        Navigator.of(
                          context,
                        ).pushNamed(Routes.categoryBrowse, arguments: category);
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
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: cartState.isEmpty
          ? null
          : _AnimatedCartFAB(
              itemCount: cartState.totalItems,
              totalRupees: cartState.items.fold<int>(
                0, (sum, item) => sum + item.totalPriceCents,
              ) / 100,
              onTap: () => Navigator.of(context).pushNamed(Routes.checkout),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
            itemBuilder: (_, _) => Column(
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

class _AnimatedCartFAB extends StatefulWidget {
  const _AnimatedCartFAB({
    required this.itemCount,
    required this.totalRupees,
    required this.onTap,
  });

  final int itemCount;
  final double totalRupees;
  final VoidCallback onTap;

  @override
  State<_AnimatedCartFAB> createState() => _AnimatedCartFABState();
}

class _AnimatedCartFABState extends State<_AnimatedCartFAB>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  int _prevCount = 0;

  @override
  void initState() {
    super.initState();
    _prevCount = widget.itemCount;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.95), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant _AnimatedCartFAB oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itemCount != _prevCount) {
      _prevCount = widget.itemCount;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalFormatted = widget.totalRupees == widget.totalRupees.truncateToDouble()
        ? '₹${widget.totalRupees.toStringAsFixed(0)}'
        : '₹${widget.totalRupees.toStringAsFixed(2)}';

    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Item count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.itemCount}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: cs.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.shopping_cart_rounded, size: 20, color: cs.onPrimary),
              const SizedBox(width: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'View Cart',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cs.onPrimary,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    totalFormatted,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: cs.onPrimary.withValues(alpha: 0.85),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward_ios, size: 14, color: cs.onPrimary.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}
