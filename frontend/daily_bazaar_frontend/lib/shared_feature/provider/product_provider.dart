import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_bazaar_frontend/shared_feature/api/product_api.dart';
import 'package:daily_bazaar_frontend/shared_feature/helper/api_exception.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/product_model.dart';
import 'package:daily_bazaar_frontend/shared_feature/config/config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// API Client & API Providers
// ─────────────────────────────────────────────────────────────────────────────

final productApiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(baseUrl: AppEnvironment.apiBaseUrl);
  ref.onDispose(client.close);
  return client;
});

final productApiProvider = Provider<ProductApi>((ref) {
  final client = ref.watch(productApiClientProvider);
  return ProductApi(client);
});

// ─────────────────────────────────────────────────────────────────────────────
// Products by Category Provider (with caching)
// ─────────────────────────────────────────────────────────────────────────────

class ProductsByCategoryParams {
  const ProductsByCategoryParams({
    required this.categoryId,
    this.limit,
    this.offset,
  });

  final String categoryId;
  final int? limit;
  final int? offset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductsByCategoryParams &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId &&
          limit == other.limit &&
          offset == other.offset;

  @override
  int get hashCode => Object.hash(categoryId, limit, offset);
}

final productsByCategoryProvider =
    FutureProvider.family<List<Product>, ProductsByCategoryParams>((
      ref,
      params,
    ) async {
      final api = ref.watch(productApiProvider);
      return api.getProductsByCategory(
        params.categoryId,
        limit: params.limit,
        offset: params.offset,
      );
    });

// Simple provider for products by category ID only
final productsByCategoryIdProvider =
    FutureProvider.family<List<Product>, String>((ref, categoryId) async {
      final api = ref.watch(productApiProvider);
      return api.getProductsByCategory(categoryId);
    });

// ─────────────────────────────────────────────────────────────────────────────
// Product by ID Provider
// ─────────────────────────────────────────────────────────────────────────────

final productByIdProvider = FutureProvider.family<Product, String>((
  ref,
  productId,
) async {
  final api = ref.watch(productApiProvider);
  return api.getProductById(productId);
});

// ─────────────────────────────────────────────────────────────────────────────
// Search Products Provider
// ─────────────────────────────────────────────────────────────────────────────

final searchProductsProvider = FutureProvider.family<List<Product>, String>((
  ref,
  query,
) async {
  if (query.trim().isEmpty) return [];
  final api = ref.watch(productApiProvider);
  return api.searchProducts(query);
});
