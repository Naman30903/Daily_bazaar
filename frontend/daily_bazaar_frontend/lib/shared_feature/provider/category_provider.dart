import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_bazaar_frontend/shared_feature/api/category_api.dart';
import 'package:daily_bazaar_frontend/shared_feature/helper/api_exception.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/category_model.dart';
import 'package:daily_bazaar_frontend/shared_feature/config/config.dart';

// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: AppEnvironment.apiBaseUrl);
});

// Provider for CategoryApi
final categoryApiProvider = Provider<CategoryApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return CategoryApi(client);
});

// Provider for all categories
final allCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final api = ref.watch(categoryApiProvider);
  return api.getAllCategories();
});

// Provider for root categories
final rootCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final api = ref.watch(categoryApiProvider);
  return api.getRootCategories();
});

// Provider for subcategories by parent ID
final subcategoriesProvider = FutureProvider.family<List<Category>, String>((
  ref,
  parentId,
) async {
  final api = ref.watch(categoryApiProvider);
  return api.getSubcategories(parentId);
});

// Provider for a single category by ID
final categoryByIdProvider = FutureProvider.family<Category, String>((
  ref,
  categoryId,
) async {
  final api = ref.watch(categoryApiProvider);
  return api.getCategoryById(categoryId);
});

// Provider for category by slug
final categoryBySlugProvider = FutureProvider.family<Category, String>((
  ref,
  slug,
) async {
  final api = ref.watch(categoryApiProvider);
  return api.getCategoryBySlug(slug);
});
