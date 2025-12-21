import 'package:daily_bazaar_frontend/shared_feature/models/home_models.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/category_grid_section.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/home_app_bar.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/offers_carousel.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/search_bar_widget.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/suggested_items_section.dart';
import 'package:flutter/material.dart';
import '../../shared_feature/widgets/bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  final List<CategoryItem> _groceryCategories = const [
    CategoryItem(
      id: '1',
      name: 'Dairy, Bread & Eggs',
      imageUrl: '',
      backgroundColor: 0xFFE3F2FD,
    ),
    CategoryItem(
      id: '2',
      name: 'Atta, Dal & Rice',
      imageUrl: '',
      backgroundColor: 0xFFFFF3E0,
    ),
    CategoryItem(
      id: '3',
      name: 'Sauces & Spreads',
      imageUrl: '',
      backgroundColor: 0xFFFCE4EC,
    ),
    CategoryItem(
      id: '4',
      name: 'Cooking Oil',
      imageUrl: '',
      backgroundColor: 0xFFF1F8E9,
    ),
    CategoryItem(
      id: '5',
      name: 'Spices',
      imageUrl: '',
      backgroundColor: 0xFFFFEBEE,
    ),
    CategoryItem(
      id: '6',
      name: 'Tea & Coffee',
      imageUrl: '',
      backgroundColor: 0xFFEDE7F6,
    ),
    CategoryItem(
      id: '7',
      name: 'Dry Fruits',
      imageUrl: '',
      backgroundColor: 0xFFFFF9C4,
    ),
    CategoryItem(
      id: '8',
      name: 'Packaged Food',
      imageUrl: '',
      backgroundColor: 0xFFE0F2F1,
    ),
  ];

  final List<CategoryItem> _snacksCategories = const [
    CategoryItem(
      id: '9',
      name: 'Chips & Namkeen',
      imageUrl: '',
      backgroundColor: 0xFFFFE0B2,
    ),
    CategoryItem(
      id: '10',
      name: 'Biscuits',
      imageUrl: '',
      backgroundColor: 0xFFD7CCC8,
    ),
    CategoryItem(
      id: '11',
      name: 'Cold Drinks',
      imageUrl: '',
      backgroundColor: 0xFFB2DFDB,
    ),
    CategoryItem(
      id: '12',
      name: 'Juices',
      imageUrl: '',
      backgroundColor: 0xFFFFCDD2,
    ),
    CategoryItem(
      id: '13',
      name: 'Chocolates',
      imageUrl: '',
      backgroundColor: 0xFFD1C4E9,
    ),
    CategoryItem(
      id: '14',
      name: 'Energy Drinks',
      imageUrl: '',
      backgroundColor: 0xFFC5CAE9,
    ),
    CategoryItem(
      id: '15',
      name: 'Ice Cream',
      imageUrl: '',
      backgroundColor: 0xFFF8BBD0,
    ),
    CategoryItem(
      id: '16',
      name: 'Sweets',
      imageUrl: '',
      backgroundColor: 0xFFFFECB3,
    ),
  ];

  final List<CategoryItem> _personalCareCategories = const [
    CategoryItem(
      id: '17',
      name: 'Bath & Body',
      imageUrl: '',
      backgroundColor: 0xFFE1F5FE,
    ),
    CategoryItem(
      id: '18',
      name: 'Hair Care',
      imageUrl: '',
      backgroundColor: 0xFFF3E5F5,
    ),
    CategoryItem(
      id: '19',
      name: 'Skin Care',
      imageUrl: '',
      backgroundColor: 0xFFFCE4EC,
    ),
    CategoryItem(
      id: '20',
      name: 'Oral Care',
      imageUrl: '',
      backgroundColor: 0xFFE8F5E9,
    ),
    CategoryItem(
      id: '21',
      name: 'Hygiene',
      imageUrl: '',
      backgroundColor: 0xFFFFF3E0,
    ),
    CategoryItem(
      id: '22',
      name: 'Fragrances',
      imageUrl: '',
      backgroundColor: 0xFFE0F2F1,
    ),
    CategoryItem(
      id: '23',
      name: 'Men\'s Grooming',
      imageUrl: '',
      backgroundColor: 0xFFECEFF1,
    ),
    CategoryItem(
      id: '24',
      name: 'Wellness',
      imageUrl: '',
      backgroundColor: 0xFFF1F8E9,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(
        deliveryAddress: 'Home - Sector 62, Noida',
        onProfileTap: () {
          // TODO: navigate to profile
        },
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
                // TODO: add to cart
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} added to cart'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            CategoryGridSection(
              title: 'Grocery & Kitchen',
              categories: _groceryCategories,
              onCategoryTap: (category) {
                // TODO: navigate to category products
              },
              onSeeAllTap: () {
                // TODO: navigate to all grocery categories
              },
            ),
            const SizedBox(height: 16),
            CategoryGridSection(
              title: 'Snacks & Drinks',
              categories: _snacksCategories,
              onCategoryTap: (category) {
                // TODO: navigate to category products
              },
              onSeeAllTap: () {
                // TODO: navigate to all snacks categories
              },
            ),
            const SizedBox(height: 16),
            CategoryGridSection(
              title: 'Personal Care',
              categories: _personalCareCategories,
              onCategoryTap: (category) {
                // TODO: navigate to category products
              },
              onSeeAllTap: () {
                // TODO: navigate to all personal care categories
              },
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
