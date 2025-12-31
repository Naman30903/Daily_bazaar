import 'package:daily_bazaar_frontend/shared_feature/models/category_model.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/product_model.dart';

abstract final class MockCategoryBrowseData {
  static const rootCategory = Category(
    id: 'root-snacks',
    name: 'Chips & Namkeen',
    slug: 'chips-namkeen',
    parentId: null,
    position: 9,
    imageUrl:
        'https://images.unsplash.com/photo-1585238342028-4e1aeb5f1d1b?auto=format&fit=crop&w=200&q=60',
  );

  static const subcategories = <Category>[
    Category(
      id: 'sub-chips-wafers',
      name: 'Chips & Wafers',
      slug: 'chips-wafers',
      parentId: 'root-snacks',
      position: 1,
      imageUrl:
          'https://images.unsplash.com/photo-1604908812278-3f8b80b9dcd0?auto=format&fit=crop&w=200&q=60',
    ),
    Category(
      id: 'sub-bhujia-mixtures',
      name: 'Bhujia & Mixtures',
      slug: 'bhujia-mixtures',
      parentId: 'root-snacks',
      position: 2,
      imageUrl:
          'https://images.unsplash.com/photo-1621939514649-280e2d6f35f4?auto=format&fit=crop&w=200&q=60',
    ),
    Category(
      id: 'sub-namkeen-snacks',
      name: 'Namkeen Snacks',
      slug: 'namkeen-snacks',
      parentId: 'root-snacks',
      position: 3,
      imageUrl:
          'https://images.unsplash.com/photo-1622445275463-afa2ab738c34?auto=format&fit=crop&w=200&q=60',
    ),
    Category(
      id: 'sub-nachos',
      name: 'Nachos',
      slug: 'nachos',
      parentId: 'root-snacks',
      position: 4,
      imageUrl:
          'https://images.unsplash.com/photo-1619535860434-8b35b9d8b8ae?auto=format&fit=crop&w=200&q=60',
    ),
    Category(
      id: 'sub-popcorn',
      name: 'Popcorn',
      slug: 'popcorn',
      parentId: 'root-snacks',
      position: 5,
      imageUrl:
          'https://images.unsplash.com/photo-1578849278619-e73505e9610f?auto=format&fit=crop&w=200&q=60',
    ),
    Category(
      id: 'sub-papad-fryums',
      name: 'Papad & Fryums',
      slug: 'papad-fryums',
      parentId: 'root-snacks',
      position: 6,
      imageUrl:
          'https://images.unsplash.com/photo-1625944525533-473f1f7df9d0?auto=format&fit=crop&w=200&q=60',
    ),
    Category(
      id: 'sub-premium',
      name: 'Premium',
      slug: 'premium',
      parentId: 'root-snacks',
      position: 7,
      imageUrl:
          'https://images.unsplash.com/photo-1528756514091-dee5ecaa3278?auto=format&fit=crop&w=200&q=60',
    ),
    Category(
      id: 'sub-gift-packs',
      name: 'Gift Packs',
      slug: 'gift-packs',
      parentId: 'root-snacks',
      position: 8,
      imageUrl:
          'https://images.unsplash.com/photo-1528825871115-3581a5387919?auto=format&fit=crop&w=200&q=60',
    ),
  ];

  static final productsBySubcategoryId = <String, List<Product>>{
    'sub-chips-wafers': _chipsAndWafers(),
    'sub-bhujia-mixtures': _bhujiaAndMixtures(),
    'sub-namkeen-snacks': _namkeenSnacks(),
    'sub-nachos': _nachos(),
    'sub-popcorn': _popcorn(),
    'sub-papad-fryums': _papadFryums(),
    'sub-premium': _premium(),
    'sub-gift-packs': _giftPacks(),
  };

  static List<Product> _chipsAndWafers() => [
    _p(
      id: 'p-lays-magic-masala',
      name: "Lay's India's Magic Masala Potato Chips",
      priceCents: 3000,
      weight: '73.7 g',
      rating: 4.6,
      reviewCount: 348000,
      deliveryMinutes: 13,
      image:
          'https://images.unsplash.com/photo-1621939514649-280e2d6f35f4?auto=format&fit=crop&w=700&q=60',
      variants: [
        _v(id: 'v-1', name: '73.7 g', priceCents: 3000, weight: '73.7 g'),
        _v(id: 'v-2', name: '120 g', priceCents: 5000, weight: '120 g'),
        _v(id: 'v-3', name: '220 g', priceCents: 8500, weight: '220 g'),
        _v(id: 'v-4', name: '35 g', priceCents: 1500, weight: '35 g'),
      ],
    ),
    _p(
      id: 'p-lays-cream-onion',
      name: "Lay's American Style Cream & Onion Potato Chips",
      priceCents: 3000,
      weight: '73.7 g',
      rating: 4.4,
      reviewCount: 241000,
      deliveryMinutes: 13,
      image:
          'https://images.unsplash.com/photo-1604908812278-3f8b80b9dcd0?auto=format&fit=crop&w=700&q=60',
      variants: [
        _v(id: 'v-1', name: '73.7 g', priceCents: 3000, weight: '73.7 g'),
        _v(id: 'v-2', name: '120 g', priceCents: 5000, weight: '120 g'),
      ],
    ),
    _p(
      id: 'p-bingo-popped',
      name: 'Bingo Popped Sour Cream & Herbs Potato Chips',
      priceCents: 3000,
      weight: '48 g',
      rating: 4.2,
      reviewCount: 1061,
      deliveryMinutes: 13,
      image:
          'https://images.unsplash.com/photo-1625944525533-473f1f7df9d0?auto=format&fit=crop&w=700&q=60',
      variants: [
        _v(id: 'v-1', name: '48 g', priceCents: 3000, weight: '48 g'),
        _v(id: 'v-2', name: '90 g', priceCents: 5200, weight: '90 g'),
        _v(id: 'v-3', name: '140 g', priceCents: 7900, weight: '140 g'),
      ],
    ),
    _p(
      id: 'p-lays-west-indies',
      name: "Lay's West Indies Hot n Sweet Chilli Flavour Potato Chips",
      priceCents: 2000,
      weight: '52.9 g',
      rating: 4.5,
      reviewCount: 212000,
      deliveryMinutes: 13,
      image:
          'https://images.unsplash.com/photo-1585238342028-4e1aeb5f1d1b?auto=format&fit=crop&w=700&q=60',
      variants: [
        _v(id: 'v-1', name: '52.9 g', priceCents: 2000, weight: '52.9 g'),
      ],
    ),
  ];

  static List<Product> _bhujiaAndMixtures() => [
    _p(
      id: 'p-bhujia-1',
      name: 'Haldiram\'s Bhujia Sev',
      priceCents: 6500,
      weight: '200 g',
      rating: 4.7,
      reviewCount: 86000,
      deliveryMinutes: 15,
      image:
          'https://images.unsplash.com/photo-1619535860434-8b35b9d8b8ae?auto=format&fit=crop&w=700&q=60',
      variants: [
        _v(id: 'v-1', name: '200 g', priceCents: 6500, weight: '200 g'),
        _v(id: 'v-2', name: '400 g', priceCents: 12000, weight: '400 g'),
      ],
    ),
    _p(
      id: 'p-mixture-1',
      name: 'Khatta Meetha Mixture',
      priceCents: 5500,
      weight: '180 g',
      rating: 4.3,
      reviewCount: 4200,
      deliveryMinutes: 15,
      image:
          'https://images.unsplash.com/photo-1528756514091-dee5ecaa3278?auto=format&fit=crop&w=700&q=60',
      variants: [
        _v(id: 'v-1', name: '180 g', priceCents: 5500, weight: '180 g'),
      ],
    ),
  ];

  static List<Product> _namkeenSnacks() => [
    _p(
      id: 'p-namkeen-1',
      name: 'Aloo Bhujia',
      priceCents: 4500,
      weight: '150 g',
      rating: 4.1,
      reviewCount: 980,
      deliveryMinutes: 14,
      image:
          'https://images.unsplash.com/photo-1622445275463-afa2ab738c34?auto=format&fit=crop&w=700&q=60',
      variants: [
        _v(id: 'v-1', name: '150 g', priceCents: 4500, weight: '150 g'),
        _v(id: 'v-2', name: '300 g', priceCents: 8200, weight: '300 g'),
      ],
    ),
  ];

  static List<Product> _nachos() => [
    _p(
      id: 'p-nachos-1',
      name: 'Cheese Nachos',
      priceCents: 9900,
      weight: '200 g',
      rating: 4.0,
      reviewCount: 1200,
      deliveryMinutes: 18,
      image:
          'https://images.unsplash.com/photo-1619535860434-8b35b9d8b8ae?auto=format&fit=crop&w=700&q=60',
      variants: [
        _v(id: 'v-1', name: '200 g', priceCents: 9900, weight: '200 g'),
      ],
    ),
  ];

  static List<Product> _popcorn() => [
    _p(
      id: 'p-popcorn-1',
      name: 'Butter Popcorn',
      priceCents: 8000,
      weight: '100 g',
      rating: 4.2,
      reviewCount: 350,
      deliveryMinutes: 12,
      image:
          'https://images.unsplash.com/photo-1578849278619-e73505e9610f?auto=format&fit=crop&w=700&q=60',
      variants: [
        _v(id: 'v-1', name: '100 g', priceCents: 8000, weight: '100 g'),
      ],
    ),
  ];

  static List<Product> _papadFryums() => [
    _p(
      id: 'p-papad-1',
      name: 'Masala Papad',
      priceCents: 3500,
      weight: '150 g',
      rating: 4.1,
      reviewCount: 2100,
      deliveryMinutes: 16,
      image:
          'https://images.unsplash.com/photo-1625944525533-473f1f7df9d0?auto=format&fit=crop&w=700&q=60',
      variants: [
        _v(id: 'v-1', name: '150 g', priceCents: 3500, weight: '150 g'),
      ],
    ),
  ];

  static List<Product> _premium() => [
    _p(
      id: 'p-premium-1',
      name: 'Imported Truffle Chips',
      priceCents: 19900,
      weight: '90 g',
      rating: 4.6,
      reviewCount: 820,
      deliveryMinutes: 20,
      image:
          'https://images.unsplash.com/photo-1585238342028-4e1aeb5f1d1b?auto=format&fit=crop&w=700&q=60',
      variants: [
        _v(id: 'v-1', name: '90 g', priceCents: 19900, weight: '90 g'),
      ],
    ),
  ];

  static List<Product> _giftPacks() => [
    _p(
      id: 'p-gift-1',
      name: 'Snack Gift Hamper',
      priceCents: 49900,
      weight: '1 pack',
      rating: 4.4,
      reviewCount: 120,
      deliveryMinutes: 30,
      image:
          'https://images.unsplash.com/photo-1528825871115-3581a5387919?auto=format&fit=crop&w=700&q=60',
      variants: [
        _v(id: 'v-1', name: '1 pack', priceCents: 49900, weight: '1 pack'),
      ],
    ),
  ];

  static Product _p({
    required String id,
    required String name,
    required int priceCents,
    required String weight,
    required String image,
    double? rating,
    int? reviewCount,
    int? deliveryMinutes,
    List<ProductVariant>? variants,
  }) {
    return Product(
      id: id,
      name: name,
      priceCents: priceCents,
      stock: 999,
      active: true,
      weight: weight,
      rating: rating,
      reviewCount: reviewCount,
      deliveryMinutes: deliveryMinutes,
      images: [
        ProductImage(id: 'img-$id', productId: id, url: image, position: 1),
      ],
      variants:
          variants ??
          [
            ProductVariant(
              id: 'v-$id',
              name: weight,
              priceCents: priceCents,
              weight: weight,
            ),
          ],
    );
  }

  static ProductVariant _v({
    required String id,
    required String name,
    required int priceCents,
    String? weight,
  }) {
    return ProductVariant(
      id: id,
      name: name,
      priceCents: priceCents,
      weight: weight,
    );
  }
}
