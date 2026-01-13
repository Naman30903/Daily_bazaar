import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cart_provider.g.dart';

/// Local cart storage using Hive
class CartStorage {
  static const String _boxName = 'cart';
  static const String _itemsKey = 'items';

  static Future<void> init() async {
    await Hive.openBox<Map>(_boxName);
  }

  static Box<Map> get _box => Hive.box<Map>(_boxName);

  /// Get cart items as Map<productId, quantity>
  static Map<String, int> getItems() {
    final raw = _box.get(_itemsKey);
    if (raw == null) return {};
    // Cast Map<dynamic, dynamic> to Map<String, int>
    return Map<String, int>.from(
      raw.map((key, value) => MapEntry(key.toString(), value as int)),
    );
  }

  /// Save cart items
  static Future<void> saveItems(Map<String, int> items) async {
    await _box.put(_itemsKey, items);
  }

  /// Clear all cart items
  static Future<void> clear() async {
    await _box.delete(_itemsKey);
  }
}

/// Cart state model
class CartState {
  const CartState({required this.items, this.isLoading = false, this.error});

  /// Map of productId -> quantity
  final Map<String, int> items;
  final bool isLoading;
  final String? error;

  int get totalItems => items.values.fold(0, (sum, qty) => sum + qty);
  int get uniqueItems => items.length;
  bool get isEmpty => items.isEmpty;

  /// Get quantity for a specific product (0 if not in cart)
  int getQuantity(String productId) => items[productId] ?? 0;

  /// Check if product is in cart
  bool contains(String productId) => items.containsKey(productId);

  CartState copyWith({
    Map<String, int>? items,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

@Riverpod(keepAlive: true)
class CartController extends _$CartController {
  @override
  CartState build() {
    // Load cart from storage on init
    final savedItems = CartStorage.getItems();
    return CartState(items: savedItems);
  }

  /// Add product to cart (sets quantity to 1)
  void addToCart(String productId) {
    final current = Map<String, int>.from(state.items);
    current[productId] = 1;
    state = state.copyWith(items: current);
    _persist();
  }

  /// Increment quantity for a product
  void incrementQuantity(String productId) {
    final current = Map<String, int>.from(state.items);
    final qty = current[productId] ?? 0;
    current[productId] = qty + 1;
    state = state.copyWith(items: current);
    _persist();
  }

  /// Decrement quantity for a product (removes if quantity becomes 0)
  void decrementQuantity(String productId) {
    final current = Map<String, int>.from(state.items);
    final qty = current[productId] ?? 0;
    if (qty <= 1) {
      current.remove(productId);
    } else {
      current[productId] = qty - 1;
    }
    state = state.copyWith(items: current);
    _persist();
  }

  /// Remove product from cart entirely
  void removeFromCart(String productId) {
    final current = Map<String, int>.from(state.items);
    current.remove(productId);
    state = state.copyWith(items: current);
    _persist();
  }

  /// Set specific quantity for a product
  void setQuantity(String productId, int quantity) {
    final current = Map<String, int>.from(state.items);
    if (quantity <= 0) {
      current.remove(productId);
    } else {
      current[productId] = quantity;
    }
    state = state.copyWith(items: current);
    _persist();
  }

  /// Clear entire cart
  void clearCart() {
    state = state.copyWith(items: {});
    _persist();
  }

  /// Persist cart to Hive storage
  void _persist() {
    CartStorage.saveItems(state.items);
  }
}
