import 'package:daily_bazaar_frontend/shared_feature/helper/api_exception.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/category_model.dart';

class CategoryApi {
  CategoryApi(this._client);

  final ApiClient _client;

  /// Get all categories: GET /api/categories
  Future<List<Category>> getAllCategories() async {
    final json = await _client.getJsonList('/api/categories');
    return json.map((item) => Category.fromJson(item)).toList();
  }

  /// Get root categories: GET /api/categories/root
  Future<List<Category>> getRootCategories() async {
    final json = await _client.getJsonList('/api/categories/root');
    return json.map((item) => Category.fromJson(item)).toList();
  }

  /// Get category by ID: GET /api/categories/{id}
  Future<Category> getCategoryById(String id) async {
    final json = await _client.getJson('/api/categories/$id');
    return Category.fromJson(json);
  }

  /// Get category by slug: GET /api/categories/by-slug/{slug}
  Future<Category> getCategoryBySlug(String slug) async {
    final json = await _client.getJson('/api/categories/by-slug/$slug');
    return Category.fromJson(json);
  }

  /// Get subcategories: GET /api/categories/subcategories/{parentId}
  Future<List<Category>> getSubcategories(String parentId) async {
    final json = await _client.getJsonList(
      '/api/categories/subcategories/$parentId',
    );
    return json.map((item) => Category.fromJson(item)).toList();
  }
}
