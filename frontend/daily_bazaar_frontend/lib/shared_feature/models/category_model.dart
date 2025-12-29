class Category {
  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.parentId,
    required this.position,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String slug;
  final String? parentId;
  final int position;

  /// NEW: optional category display image
  final String? imageUrl;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      parentId: json['parent_id']?.toString(),
      position: (json['position'] as num?)?.toInt() ?? 0,
      imageUrl: json['image_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    if (parentId != null) 'parent_id': parentId,
    'position': position,
    if (imageUrl != null) 'image_url': imageUrl,
  };

  Category copyWith({
    String? id,
    String? name,
    String? slug,
    String? parentId,
    int? position,
    String? imageUrl,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      parentId: parentId ?? this.parentId,
      position: position ?? this.position,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
