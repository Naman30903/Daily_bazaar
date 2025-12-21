import 'package:flutter/material.dart';
import '../models/home_models.dart';
import 'product_card.dart';

class SuggestedItemsSection extends StatelessWidget {
  const SuggestedItemsSection({
    super.key,
    required this.products,
    this.onProductTap,
    this.onAddToCart,
  });

  final List<SuggestedProduct> products;
  final ValueChanged<SuggestedProduct>? onProductTap;
  final ValueChanged<SuggestedProduct>? onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Suggested for You',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // TODO: navigate to full list
                },
                child: const Text('See all'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ProductCard(
                  product: product,
                  onTap: () => onProductTap?.call(product),
                  onAddToCart: () => onAddToCart?.call(product),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
