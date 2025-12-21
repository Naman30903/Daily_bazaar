class OfferBanner {
  const OfferBanner({
    required this.id,
    required this.imageUrl,
    required this.title,
    this.subtitle,
  });

  final String id;
  final String imageUrl;
  final String title;
  final String? subtitle;
}

class SuggestedProduct {
  const SuggestedProduct({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    this.discount,
  });

  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final String? discount;
}

class CategoryItem {
  const CategoryItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.backgroundColor,
  });

  final String id;
  final String name;
  final String imageUrl;
  final int? backgroundColor;
}
