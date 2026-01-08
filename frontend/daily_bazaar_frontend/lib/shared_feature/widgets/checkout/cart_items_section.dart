import 'package:daily_bazaar_frontend/shared_feature/models/checkout_models.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/checkout/cart_item_tile.dart';
import 'package:flutter/material.dart';

/// Cart items section
class CartItemsSection extends StatelessWidget {
  const CartItemsSection({
    super.key,
    required this.cartItems,
    required this.onIncrementQuantity,
    required this.onDecrementQuantity,
  });

  final List<CartItem> cartItems;
  final Function(String) onIncrementQuantity;
  final Function(String) onDecrementQuantity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: cartItems.map((item) {
          return CartItemTile(
            cartItem: item,
            onIncrement: () => onIncrementQuantity(item.id),
            onDecrement: () => onDecrementQuantity(item.id),
            onMoveToWishlist: () {
              // TODO: Implement move to wishlist
            },
          );
        }).toList(),
      ),
    );
  }
}
