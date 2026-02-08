import 'package:daily_bazaar_frontend/shared_feature/helper/api_exception.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/product_model.dart';

class ProductApi {
  ProductApi(this._client);

  final ApiClient _client;

  /// Get products by category using SQL RPC: GET /api/category-products-sql/{categoryId}
  /// Returns full product data including images, variants, and categories
  Future<List<Product>> getProductsByCategory(
    String categoryId, {
    int? limit,
    int? offset,
  }) async {
    // Use the SQL-based endpoint for full product data
    String path = '/api/category-products-sql/$categoryId';

    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();

    if (queryParams.isNotEmpty) {
      final query = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      path = '$path?$query';
    }

    final json = await _client.getJsonList(path);
    return json.map((item) => Product.fromJson(item)).toList();
  }

  /// Get all products: GET /api/products
  Future<List<Product>> getAllProducts({
    List<String>? categoryIds,
    int? limit,
    int? offset,
  }) async {
    String path = '/api/products';

    final queryParams = <String, String>{};
    if (categoryIds != null && categoryIds.isNotEmpty) {
      queryParams['category_ids'] = categoryIds.join(',');
    }
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();

    if (queryParams.isNotEmpty) {
      final query = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      path = '$path?$query';
    }

    final json = await _client.getJsonList(path);
    return json.map((item) => Product.fromJson(item)).toList();
  }

  /// Get product by ID: GET /api/products/{id}
  Future<Product> getProductById(String id) async {
    final json = await _client.getJson('/api/products/$id');
    return Product.fromJson(json);
  }

  /// Search products: GET /api/products/search?q={query}
  Future<List<Product>> searchProducts(
    String query, {
    int? limit,
    int? offset,
  }) async {
    String path = '/api/products/search?q=$query';
    if (limit != null) path += '&limit=$limit';
    if (offset != null) path += '&offset=$offset';
    final json = await _client.getJsonList(path);
    return json.map((item) => Product.fromJson(item)).toList();
  }

  /// Get search suggestions for autocomplete: GET /api/products/suggestions?q={query}
  Future<List<String>> getSearchSuggestions(
    String query, {
    int limit = 10,
  }) async {
    if (query.isEmpty) return [];
    final json = await _client.getJsonList(
      '/api/products/suggestions?q=$query&limit=$limit',
    );
    return json.map((item) => item.toString()).toList();
  }
}
