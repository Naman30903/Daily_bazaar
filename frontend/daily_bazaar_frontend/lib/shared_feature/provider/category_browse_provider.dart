import 'dart:async';

import 'package:daily_bazaar_frontend/shared_feature/models/category_model.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/mock_data.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/product_model.dart';
import 'package:daily_bazaar_frontend/shared_feature/provider/category_provider.dart';
import 'package:daily_bazaar_frontend/shared_feature/provider/product_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_browse_provider.g.dart';

class CategoryBrowseState {
  const CategoryBrowseState({
    this.subcategories = const [],
    this.selectedSubcategoryId,
    this.products = const [],
    this.isLoadingSubcategories = false,
    this.isLoadingProducts = false,
    this.subcategoriesError,
    this.productsError,
    this.hasMoreProducts = false,
    this.currentOffset = 0,
  });

  final List<Category> subcategories;
  final String? selectedSubcategoryId;
  final List<Product> products;

  final bool isLoadingSubcategories;
  final bool isLoadingProducts;

  final String? subcategoriesError;
  final String? productsError;

  final bool hasMoreProducts;
  final int currentOffset;

  Category? get selectedSubcategory {
    final id = selectedSubcategoryId;
    if (id == null) return null;
    for (final c in subcategories) {
      if (c.id == id) return c;
    }
    return null;
  }

  CategoryBrowseState copyWith({
    List<Category>? subcategories,
    String? selectedSubcategoryId,
    List<Product>? products,
    bool? isLoadingSubcategories,
    bool? isLoadingProducts,
    String? subcategoriesError,
    bool clearSubcategoriesError = false,
    String? productsError,
    bool clearProductsError = false,
    bool? hasMoreProducts,
    int? currentOffset,
  }) {
    return CategoryBrowseState(
      subcategories: subcategories ?? this.subcategories,
      selectedSubcategoryId:
          selectedSubcategoryId ?? this.selectedSubcategoryId,
      products: products ?? this.products,
      isLoadingSubcategories:
          isLoadingSubcategories ?? this.isLoadingSubcategories,
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      subcategoriesError: clearSubcategoriesError
          ? null
          : (subcategoriesError ?? this.subcategoriesError),
      productsError: clearProductsError
          ? null
          : (productsError ?? this.productsError),
      hasMoreProducts: hasMoreProducts ?? this.hasMoreProducts,
      currentOffset: currentOffset ?? this.currentOffset,
    );
  }
}

@riverpod
class CategoryBrowseController extends _$CategoryBrowseController {
  static const int _pageSize = 20;

  final Map<String, List<Product>> _productsCache = {};
  Timer? _debounce;

  // Toggle mock mode quickly while UI building.
  static const bool _useMock = true;

  @override
  Future<CategoryBrowseState> build(String parentCategoryId) async {
    ref.onDispose(() => _debounce?.cancel());

    if (_useMock) {
      final subcats = MockCategoryBrowseData.subcategories;
      final selected = subcats.isNotEmpty ? subcats.first.id : null;
      final products = selected == null
          ? <Product>[]
          : (MockCategoryBrowseData.productsBySubcategoryId[selected] ??
                const <Product>[]);

      _productsCache.clear();
      if (selected != null) {
        _productsCache[selected] = products;
      }

      return CategoryBrowseState(
        subcategories: subcats,
        selectedSubcategoryId: selected,
        products: products,
        hasMoreProducts: false,
      );
    }

    // load subcategories
    final subcats = await _loadSubcategories(parentCategoryId);

    // auto-select first
    String? selected;
    List<Product> products = [];

    if (subcats.isNotEmpty) {
      selected = subcats.first.id;
      products = await _loadProducts(selected);
      _productsCache[selected] = products;
    }

    return CategoryBrowseState(
      subcategories: subcats,
      selectedSubcategoryId: selected,
      products: products,
      hasMoreProducts: products.length >= _pageSize,
    );
  }

  Future<List<Category>> _loadSubcategories(String parentId) async {
    if (_useMock) return MockCategoryBrowseData.subcategories;
    final api = ref.read(categoryApiProvider);
    return api.getSubcategories(parentId);
  }

  Future<List<Product>> _loadProducts(
    String categoryId, {
    int offset = 0,
  }) async {
    if (_useMock) {
      // mimic pagination in mock mode
      final all =
          MockCategoryBrowseData.productsBySubcategoryId[categoryId] ??
          const <Product>[];
      final start = offset;
      final end = (offset + _pageSize) > all.length
          ? all.length
          : (offset + _pageSize);
      if (start >= all.length) return const <Product>[];
      return all.sublist(start, end);
    }

    final api = ref.read(productApiProvider);
    return api.getProductsByCategory(
      categoryId,
      limit: _pageSize,
      offset: offset,
    );
  }

  void selectSubcategory(String subcategoryId) {
    // debounce rapid switching
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 180), () async {
      await _selectSubcategoryInternal(subcategoryId);
    });
  }

  Future<void> _selectSubcategoryInternal(String subcategoryId) async {
    final current = state.asData?.value; // was: state.valueOrNull
    if (current == null) return;
    if (current.selectedSubcategoryId == subcategoryId) return;

    // cache hit
    final cached = _productsCache[subcategoryId];
    if (cached != null) {
      state = AsyncData(
        current.copyWith(
          selectedSubcategoryId: subcategoryId,
          products: cached,
          currentOffset: 0,
          hasMoreProducts: cached.length >= _pageSize,
          clearProductsError: true,
        ),
      );
      return;
    }

    // show loading (keep sidebar stable)
    state = AsyncData(
      current.copyWith(
        selectedSubcategoryId: subcategoryId,
        isLoadingProducts: true,
        clearProductsError: true,
      ),
    );

    try {
      final products = await _loadProducts(subcategoryId);
      _productsCache[subcategoryId] = products;

      final latest = state.asData?.value; // was: state.valueOrNull
      if (latest?.selectedSubcategoryId != subcategoryId) return;

      state = AsyncData(
        latest!.copyWith(
          products: products,
          isLoadingProducts: false,
          hasMoreProducts: products.length >= _pageSize,
          currentOffset: 0,
        ),
      );
    } catch (e) {
      final latest = state.asData?.value; // was: state.valueOrNull
      if (latest?.selectedSubcategoryId != subcategoryId) return;

      state = AsyncData(
        latest!.copyWith(
          products: const [],
          isLoadingProducts: false,
          productsError: e.toString(),
        ),
      );
    }
  }

  Future<void> loadMoreProducts() async {
    final current = state.asData?.value; // was: state.valueOrNull
    if (current == null) return;
    if (current.isLoadingProducts) return;
    if (!current.hasMoreProducts) return;

    final categoryId = current.selectedSubcategoryId;
    if (categoryId == null) return;

    final nextOffset = current.currentOffset + _pageSize;

    state = AsyncData(current.copyWith(isLoadingProducts: true));

    try {
      final more = await _loadProducts(categoryId, offset: nextOffset);
      final all = [...current.products, ...more];
      _productsCache[categoryId] = all;

      state = AsyncData(
        current.copyWith(
          products: all,
          isLoadingProducts: false,
          hasMoreProducts: more.length >= _pageSize,
          currentOffset: nextOffset,
        ),
      );
    } catch (e) {
      state = AsyncData(
        current.copyWith(isLoadingProducts: false, productsError: e.toString()),
      );
    }
  }

  Future<void> refreshProducts() async {
    final current = state.asData?.value; // was: state.valueOrNull
    if (current == null) return;

    final categoryId = current.selectedSubcategoryId;
    if (categoryId == null) return;

    _productsCache.remove(categoryId);

    state = AsyncData(
      current.copyWith(isLoadingProducts: true, clearProductsError: true),
    );

    try {
      final products = await _loadProducts(categoryId);
      _productsCache[categoryId] = products;

      state = AsyncData(
        current.copyWith(
          products: products,
          isLoadingProducts: false,
          hasMoreProducts: products.length >= _pageSize,
          currentOffset: 0,
        ),
      );
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          products: const [],
          isLoadingProducts: false,
          productsError: e.toString(),
        ),
      );
    }
  }
}
