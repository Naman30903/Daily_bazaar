import 'package:flutter/material.dart';
import '../shared_feature/constant/product_detail_theme.dart';
import '../shared_feature/models/product_model.dart';
import '../shared_feature/widgets/product_detail/product_image_carousel.dart';
import '../shared_feature/widgets/product_detail/product_info_card.dart';
import '../shared_feature/widgets/product_detail/price_section.dart';
import '../shared_feature/widgets/product_detail/product_actions.dart';
import '../shared_feature/widgets/product_detail/similar_products_carousel.dart';
import '../shared_feature/widgets/product_detail/sticky_add_to_cart_bar.dart';

/// Product detail screen matching the grocery app UI design.
/// Displays product images, info, pricing, actions, similar products,
/// and a sticky bottom bar for adding to cart.
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.product,
    this.similarProducts = const [],
  });

  final Product product;
  final List<Product> similarProducts;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isWishlisted = false;
  bool _isDetailsExpanded = false;
  bool _isAddingToCart = false;
  final Set<String> _wishlistedSimilarIds = {};

  Product get product => widget.product;

  List<String> get _imageUrls {
    if (product.images != null && product.images!.isNotEmpty) {
      return product.images!.map((img) => img.url).toList();
    }
    return [];
  }

  String? get _brandName {
    // Extract brand from metadata or use first category name
    if (product.metadata != null && product.metadata!['brand'] != null) {
      return product.metadata!['brand'].toString();
    }
    if (product.categories != null && product.categories!.isNotEmpty) {
      return product.categories!.first.name;
    }
    return null;
  }

  String? get _brandLogoUrl {
    if (product.metadata != null && product.metadata!['brand_logo'] != null) {
      return product.metadata!['brand_logo'].toString();
    }
    return null;
  }

  void _handleClose() {
    Navigator.of(context).pop();
  }

  void _handleWishlistTap() {
    setState(() {
      _isWishlisted = !_isWishlisted;
    });
    // TODO: Implement wishlist API call
  }

  void _handleSearchTap() {
    // TODO: Implement search functionality
  }

  void _handleShareTap() {
    // TODO: Implement share functionality
  }

  void _handleViewDetailsTap() {
    setState(() {
      _isDetailsExpanded = !_isDetailsExpanded;
    });
    // TODO: Show product details expansion
  }

  void _handleExploreBrandTap() {
    // TODO: Navigate to brand products page
  }

  void _handleSimilarProductTap(Product similarProduct) {
    // Navigate to the similar product's detail page
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          product: similarProduct,
          similarProducts: widget.similarProducts,
        ),
      ),
    );
  }

  void _handleSimilarProductAdd(Product similarProduct) {
    // TODO: Add to cart API call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${similarProduct.name} added to cart'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleSimilarProductWishlist(Product similarProduct) {
    setState(() {
      if (_wishlistedSimilarIds.contains(similarProduct.id)) {
        _wishlistedSimilarIds.remove(similarProduct.id);
      } else {
        _wishlistedSimilarIds.add(similarProduct.id);
      }
    });
  }

  Future<void> _handleAddToCart() async {
    setState(() {
      _isAddingToCart = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      _isAddingToCart = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        backgroundColor: ProductDetailTheme.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProductDetailTheme.backgroundDark,
      body: Stack(
        children: [
          // Scrollable content
          CustomScrollView(
            slivers: [
              // Product image carousel (not a sliver, wrapped)
              SliverToBoxAdapter(
                child: ProductImageCarousel(
                  imageUrls: _imageUrls,
                  isWishlisted: _isWishlisted,
                  onClose: _handleClose,
                  onWishlistTap: _handleWishlistTap,
                  onSearchTap: _handleSearchTap,
                  onShareTap: _handleShareTap,
                ),
              ),

              // Product info card
              SliverToBoxAdapter(
                child: ProductInfoCard(
                  name: product.name,
                  weight: product.weight,
                  isVeg: true, // TODO: Get from product metadata
                  deliveryMinutes: product.deliveryMinutes,
                  rating: product.rating,
                  reviewCount: product.reviewCount,
                ),
              ),

              // Price section
              SliverToBoxAdapter(
                child: PriceSection(
                  price: product.formattedPrice,
                  mrp: product.formattedMrp,
                  discountPercent: product.discountPercent,
                ),
              ),

              // Product actions
              SliverToBoxAdapter(
                child: ProductActions(
                  isDetailsExpanded: _isDetailsExpanded,
                  onViewDetailsTap: _handleViewDetailsTap,
                  brandName: _brandName,
                  brandLogoUrl: _brandLogoUrl,
                  onExploreBrandTap: _handleExploreBrandTap,
                ),
              ),

              // Spacer
              const SliverToBoxAdapter(
                child: SizedBox(height: ProductDetailTheme.space16),
              ),

              // Similar products carousel
              if (widget.similarProducts.isNotEmpty)
                SliverToBoxAdapter(
                  child: SimilarProductsCarousel(
                    products: widget.similarProducts,
                    wishlistedIds: _wishlistedSimilarIds,
                    onProductTap: _handleSimilarProductTap,
                    onAddTap: _handleSimilarProductAdd,
                    onWishlistTap: _handleSimilarProductWishlist,
                  ),
                ),

              // Bottom padding for sticky bar
              SliverToBoxAdapter(
                child: SizedBox(
                  height: ProductDetailTheme.stickyBarHeight +
                      MediaQuery.of(context).padding.bottom +
                      ProductDetailTheme.space16,
                ),
              ),
            ],
          ),

          // Sticky bottom bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: StickyAddToCartBar(
              price: product.formattedPrice,
              weight: product.weight,
              mrp: product.formattedMrp,
              discountPercent: product.discountPercent,
              isLoading: _isAddingToCart,
              onAddToCart: _handleAddToCart,
            ),
          ),
        ],
      ),
    );
  }
}
