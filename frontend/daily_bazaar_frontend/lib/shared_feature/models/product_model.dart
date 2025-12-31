class Product {
  const Product({
    required this.id,
    required this.name,
    this.description,
    this.sku,
    required this.priceCents,
    required this.stock,
    required this.active,
    this.createdAt,
    this.metadata,
    this.categories,
    this.images,
    this.variants,
    this.rating,
    this.reviewCount,
    this.deliveryMinutes,
    this.weight,
  });

  final String id;
  final String name;
  final String? description;
  final String? sku;
  final int priceCents;
  final int stock;
  final bool active;
  final DateTime? createdAt;
  final Map<String, dynamic>? metadata;
  final List<ProductCategory>? categories;
  final List<ProductImage>? images;
  final List<ProductVariant>? variants;
  final double? rating;
  final int? reviewCount;
  final int? deliveryMinutes;
  final String? weight;

  double get priceInRupees => priceCents / 100;

  String get formattedPrice => '₹${priceInRupees.toStringAsFixed(0)}';

  String? get primaryImageUrl =>
      images?.isNotEmpty == true ? images!.first.url : null;

  bool get hasVariants => variants != null && variants!.length > 1;

  int get variantCount => variants?.length ?? 1;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      sku: json['sku']?.toString(),
      priceCents: (json['price_cents'] as num?)?.toInt() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      active: json['active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => ProductCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      variants: (json['variants'] as List<dynamic>?)
          ?.map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
          .toList(),
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: (json['review_count'] as num?)?.toInt(),
      deliveryMinutes: (json['delivery_minutes'] as num?)?.toInt(),
      weight: json['weight']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (description != null) 'description': description,
    if (sku != null) 'sku': sku,
    'price_cents': priceCents,
    'stock': stock,
    'active': active,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (metadata != null) 'metadata': metadata,
  };
}

class ProductCategory {
  const ProductCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.position,
  });

  final String id;
  final String name;
  final String slug;
  final int? position;

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      position: (json['position'] as num?)?.toInt(),
    );
  }
}

class ProductImage {
  const ProductImage({
    required this.id,
    required this.productId,
    required this.url,
    this.position,
  });

  final String id;
  final String productId;
  final String url;
  final int? position;

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      position: (json['position'] as num?)?.toInt(),
    );
  }
}

class ProductVariant {
  const ProductVariant({
    required this.id,
    required this.name,
    required this.priceCents,
    this.weight,
  });

  final String id;
  final String name;
  final int priceCents;
  final String? weight;

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      priceCents: (json['price_cents'] as num?)?.toInt() ?? 0,
      weight: json['weight']?.toString(),
    );
  }
}

class ProductListResponse {
  const ProductListResponse({
    required this.products,
    required this.total,
    required this.hasMore,
  });

  final List<Product> products;
  final int total;
  final bool hasMore;

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      products:
          (json['products'] as List<dynamic>?)
              ?.map((e) => Product.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: (json['total'] as num?)?.toInt() ?? 0,
      hasMore: json['has_more'] as bool? ?? false,
    );
  }
}
