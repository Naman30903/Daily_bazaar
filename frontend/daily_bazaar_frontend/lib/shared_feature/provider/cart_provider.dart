import 'dart:convert';
import 'package:daily_bazaar_frontend/shared_feature/models/checkout_models.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/product_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cart_provider.g.dart';

/// Local cart storage using Hive
class CartStorage {
  static const String _boxName = 'cart';
  static const String _itemsKey = 'cart_items';

  static Box<String> get _box => Hive.box<String>(_boxName);

  /// Get cart items from storage
  static List<CartItem> getItems() {
    final raw = _box.get(_itemsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((item) => _cartItemFromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Save cart items to storage
  static Future<void> saveItems(List<CartItem> items) async {
    final encoded = jsonEncode(
      items.map((item) => _cartItemToJson(item)).toList(),
    );
    await _box.put(_itemsKey, encoded);
  }

  /// Clear all cart items
  static Future<void> clear() async {
    await _box.delete(_itemsKey);
  }

  /// Convert CartItem to JSON-serializable map
  static Map<String, dynamic> _cartItemToJson(CartItem item) {
    return {
      'id': item.id,
      'product': item.product.toJson(),
      'quantity': item.quantity,
      'priceCentsSnapshot': item.priceCentsSnapshot,
      'mrpCentsSnapshot': item.mrpCentsSnapshot,
    };
  }

  /// Convert JSON map to CartItem
  static CartItem _cartItemFromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      priceCentsSnapshot: json['priceCentsSnapshot'] as int,
      mrpCentsSnapshot: json['mrpCentsSnapshot'] as int?,
    );
  }
}

/// Cart state model
class CartState {
  const CartState({required this.items, this.isLoading = false, this.error});

  final List<CartItem> items;
  final bool isLoading;
  final String? error;

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  int get uniqueItems => items.length;
  bool get isEmpty => items.isEmpty;

  /// Get quantity for a specific product (0 if not in cart)
  int getQuantity(String productId) {
    final item = items.where((i) => i.product.id == productId).firstOrNull;
    return item?.quantity ?? 0;
  }

  /// Check if product is in cart
  bool contains(String productId) =>
      items.any((item) => item.product.id == productId);

  /// Get cart item by product ID
  CartItem? getItem(String productId) =>
      items.where((i) => i.product.id == productId).firstOrNull;

  /// Get all cart items (for checkout)
  List<CartItem> get cartItems => items;

  CartState copyWith({
    List<CartItem>? items,
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
  void addToCart(Product product) {
    final current = List<CartItem>.from(state.items);

    // Check if already in cart
    final existingIndex = current.indexWhere((i) => i.product.id == product.id);
    if (existingIndex >= 0) {
      // Increment existing
      final existing = current[existingIndex];
      current[existingIndex] = existing.copyWith(
        quantity: existing.quantity + 1,
      );
    } else {
      // Add new item
      current.add(
        CartItem(
          id: 'cart_${product.id}_${DateTime.now().millisecondsSinceEpoch}',
          product: product,
          quantity: 1,
          priceCentsSnapshot: product.priceCents,
          mrpCentsSnapshot: product.mrpCents,
        ),
      );
    }

    state = state.copyWith(items: current);
    _persist();
  }

  /// Increment quantity for a product
  void incrementQuantity(String productId) {
    final current = List<CartItem>.from(state.items);
    final index = current.indexWhere((i) => i.product.id == productId);

    if (index >= 0) {
      final item = current[index];
      current[index] = item.copyWith(quantity: item.quantity + 1);
      state = state.copyWith(items: current);
      _persist();
    }
  }

  /// Decrement quantity for a product (removes if quantity becomes 0)
  void decrementQuantity(String productId) {
    final current = List<CartItem>.from(state.items);
    final index = current.indexWhere((i) => i.product.id == productId);

    if (index >= 0) {
      final item = current[index];
      if (item.quantity <= 1) {
        current.removeAt(index);
      } else {
        current[index] = item.copyWith(quantity: item.quantity - 1);
      }
      state = state.copyWith(items: current);
      _persist();
    }
  }

  /// Remove product from cart entirely
  void removeFromCart(String productId) {
    final current = List<CartItem>.from(state.items);
    current.removeWhere((i) => i.product.id == productId);
    state = state.copyWith(items: current);
    _persist();
  }

  /// Set specific quantity for a product
  void setQuantity(String productId, int quantity) {
    final current = List<CartItem>.from(state.items);
    final index = current.indexWhere((i) => i.product.id == productId);

    if (index >= 0) {
      if (quantity <= 0) {
        current.removeAt(index);
      } else {
        current[index] = current[index].copyWith(quantity: quantity);
      }
      state = state.copyWith(items: current);
      _persist();
    }
  }

  /// Clear entire cart
  void clearCart() {
    state = state.copyWith(items: []);
    _persist();
  }

  /// Persist cart to Hive storage
  void _persist() {
    CartStorage.saveItems(state.items);
  }
}
