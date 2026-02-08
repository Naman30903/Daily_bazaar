import 'package:daily_bazaar_frontend/core/utils/responsive.dart';
import 'package:daily_bazaar_frontend/routes/route.dart';
import 'package:daily_bazaar_frontend/shared_feature/helper/debouncer.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/product_model.dart';
import 'package:daily_bazaar_frontend/shared_feature/provider/cart_provider.dart';
import 'package:daily_bazaar_frontend/shared_feature/provider/search_provider.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/product_card_browse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Search page with autocomplete suggestions and product grid.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final Debouncer _debouncer = Debouncer(
    delay: const Duration(milliseconds: 300),
  );
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;

  bool _showSuggestions = true;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      // Perform initial search
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(searchControllerProvider.notifier)
            .searchProducts(widget.initialQuery!);
        setState(() => _showSuggestions = false);
      });
    } else {
      // Focus the search field
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debouncer.run(() {
      ref.read(searchControllerProvider.notifier).updateQuery(query);
    });
    setState(() => _showSuggestions = true);
  }

  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    _focusNode.unfocus();
    setState(() => _showSuggestions = false);
    ref.read(searchControllerProvider.notifier).selectSuggestion(suggestion);
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    _focusNode.unfocus();
    setState(() => _showSuggestions = false);
    ref.read(searchControllerProvider.notifier).searchProducts(query);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchControllerProvider.notifier).clear();
    setState(() => _showSuggestions = true);
    _focusNode.requestFocus();
  }

  Future<void> _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize();
      setState(() {});
    } catch (e) {
      debugPrint('Speech initialization failed: $e');
    }
  }

  void _startListening() async {
    if (!_speechEnabled) {
      // Try initializing again if it failed previously
      await _initSpeech();
      if (!_speechEnabled) return;
    }

    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _searchController.text = result.recognizedWords;
      // selection is maintained at end
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    });

    // Update suggestions while typing
    _onSearchChanged(result.recognizedWords);

    if (result.finalResult) {
      setState(() {
        _isListening = false;
      });
      _onSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final searchState = ref.watch(searchControllerProvider);
    final cartState = ref.watch(cartControllerProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: _SearchTextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: _onSearchChanged,
          onSubmitted: (_) => _onSearch(),
          onClear: _clearSearch,
        ),
        actions: [
          IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
            color: _isListening ? cs.primary : cs.onSurfaceVariant,
            onPressed: () {
              if (_isListening) {
                _stopListening();
              } else {
                _startListening();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search suggestions
          if (_showSuggestions && searchState.hasSuggestions)
            _SuggestionsList(
              suggestions: searchState.suggestions,
              query: searchState.query,
              onTap: _onSuggestionTap,
              isLoading: searchState.isLoadingSuggestions,
            ),

          // Filter chips (only show when we have results or are searching)
          if (!_showSuggestions || searchState.hasResults) _FilterChipsRow(),

          // Search results
          if (!_showSuggestions || searchState.hasResults)
            Expanded(
              child: _SearchResults(
                products: searchState.results,
                isLoading: searchState.isLoadingResults,
                error: searchState.error,
                onProductTap: (product) {
                  Navigator.of(context).pushNamed(
                    Routes.productDetail,
                    arguments: {
                      'product': product,
                      'similarProducts': <Product>[],
                    },
                  );
                },
                onAddToCart: (product) {
                  ref.read(cartControllerProvider.notifier).addToCart(product);
                },
                getCartQuantity: (productId) {
                  return cartState.getQuantity(productId);
                },
                onIncrementCart: (product) {
                  ref
                      .read(cartControllerProvider.notifier)
                      .incrementQuantity(product.id);
                },
                onDecrementCart: (product) {
                  ref
                      .read(cartControllerProvider.notifier)
                      .decrementQuantity(product.id);
                },
              ),
            ),

          // Initial state - show suggestions placeholder
          if (_showSuggestions &&
              !searchState.hasSuggestions &&
              !searchState.hasQuery)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search,
                      size: 64,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Search for products',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: cartState.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).pushNamed(Routes.checkout),
              label: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'View Cart',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${cartState.totalItems} ${cartState.totalItems == 1 ? 'item' : 'items'}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
              icon: const Icon(Icons.shopping_cart_outlined),
              shape: const StadiumBorder(),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _SearchTextField extends StatelessWidget {
  const _SearchTextField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 44,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search, color: cs.onSurfaceVariant, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search for products...',
                hintStyle: TextStyle(color: cs.onSurfaceVariant),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.close, color: cs.onSurfaceVariant, size: 20),
              onPressed: onClear,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
        ],
      ),
    );
  }
}

class _SuggestionsList extends StatelessWidget {
  const _SuggestionsList({
    required this.suggestions,
    required this.query,
    required this.onTap,
    required this.isLoading,
  });

  final List<String> suggestions;
  final String query;
  final ValueChanged<String> onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return _SuggestionItem(
            suggestion: suggestion,
            query: query,
            onTap: () => onTap(suggestion),
          );
        },
      ),
    );
  }
}

class _SuggestionItem extends StatelessWidget {
  const _SuggestionItem({
    required this.suggestion,
    required this.query,
    required this.onTap,
  });

  final String suggestion;
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Highlight the matching part
    final lowerSuggestion = suggestion.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matchStart = lowerSuggestion.indexOf(lowerQuery);

    Widget textWidget;
    if (matchStart >= 0 && query.isNotEmpty) {
      final before = suggestion.substring(0, matchStart);
      final match = suggestion.substring(matchStart, matchStart + query.length);
      final after = suggestion.substring(matchStart + query.length);

      textWidget = RichText(
        text: TextSpan(
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: cs.onSurface),
          children: [
            TextSpan(text: before),
            TextSpan(
              text: match,
              style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary),
            ),
            TextSpan(text: after),
          ],
        ),
      );
    } else {
      textWidget = Text(
        suggestion,
        style: Theme.of(context).textTheme.bodyLarge,
      );
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.history, size: 18, color: cs.onSurfaceVariant),
            ),
            const SizedBox(width: 12),
            Expanded(child: textWidget),
            Icon(
              Icons.north_west,
              size: 18,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          _FilterChip(label: 'Filters', icon: Icons.tune, onTap: () {}),
          const SizedBox(width: 8),
          _FilterChip(label: 'Sort', icon: Icons.swap_vert, onTap: () {}),
          const SizedBox(width: 8),
          _FilterChip(label: 'Price', onTap: () {}),
          const SizedBox(width: 8),
          _FilterChip(label: 'Quantity', onTap: () {}),
          const SizedBox(width: 8),
          _FilterChip(label: 'Processing Type', onTap: () {}),
          const SizedBox(width: 8),
          _FilterChip(label: 'Tags', onTap: () {}),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.icon, required this.onTap});

  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.products,
    required this.isLoading,
    this.error,
    required this.onProductTap,
    required this.onAddToCart,
    required this.getCartQuantity,
    required this.onIncrementCart,
    required this.onDecrementCart,
  });

  final List<Product> products;
  final bool isLoading;
  final String? error;
  final ValueChanged<Product> onProductTap;
  final ValueChanged<Product> onAddToCart;
  final int Function(String) getCartQuantity;
  final ValueChanged<Product> onIncrementCart;
  final ValueChanged<Product> onDecrementCart;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Loading state
    if (isLoading && products.isEmpty) {
      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Responsive.isDesktop(context)
              ? 5
              : Responsive.isTablet(context)
              ? 4
              : 2,
          childAspectRatio: 0.58,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (_, _) => Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    // Error state
    if (error != null && products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: cs.error),
              const SizedBox(height: 12),
              Text(
                'Search failed',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: cs.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: cs.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try a different search term',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    // Results grid
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.isDesktop(context)
            ? 5
            : Responsive.isTablet(context)
            ? 4
            : 2,
        childAspectRatio: 0.58,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final cartQty = getCartQuantity(product.id);
        return ProductCardBrowse(
          product: product,
          onTap: () => onProductTap(product),
          onAddToCart: () => onAddToCart(product),
          cartQuantity: cartQty,
          onIncrement: () => onIncrementCart(product),
          onDecrement: () => onDecrementCart(product),
        );
      },
    );
  }
}
