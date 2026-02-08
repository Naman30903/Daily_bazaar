import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/product_model.dart';
import 'package:daily_bazaar_frontend/shared_feature/provider/product_provider.dart';

/// State for search functionality
class SearchState {
  final String query;
  final List<String> suggestions;
  final List<Product> results;
  final bool isLoadingSuggestions;
  final bool isLoadingResults;
  final String? error;

  const SearchState({
    this.query = '',
    this.suggestions = const [],
    this.results = const [],
    this.isLoadingSuggestions = false,
    this.isLoadingResults = false,
    this.error,
  });

  SearchState copyWith({
    String? query,
    List<String>? suggestions,
    List<Product>? results,
    bool? isLoadingSuggestions,
    bool? isLoadingResults,
    String? error,
    bool clearError = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      suggestions: suggestions ?? this.suggestions,
      results: results ?? this.results,
      isLoadingSuggestions: isLoadingSuggestions ?? this.isLoadingSuggestions,
      isLoadingResults: isLoadingResults ?? this.isLoadingResults,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get hasQuery => query.isNotEmpty;
  bool get hasResults => results.isNotEmpty;
  bool get hasSuggestions => suggestions.isNotEmpty;
}

/// Controller for search functionality
class SearchController extends Notifier<SearchState> {
  @override
  SearchState build() {
    return const SearchState();
  }

  /// Updates the search query and fetches suggestions
  Future<void> updateQuery(String query) async {
    if (query == state.query) return;

    state = state.copyWith(query: query, clearError: true);

    if (query.isEmpty) {
      state = state.copyWith(
        suggestions: [],
        results: [],
        isLoadingSuggestions: false,
        isLoadingResults: false,
      );
      return;
    }

    // Fetch suggestions for autocomplete
    await fetchSuggestions(query);
  }

  /// Fetches search suggestions for the given query
  Future<void> fetchSuggestions(String query) async {
    if (query.isEmpty) return;

    state = state.copyWith(isLoadingSuggestions: true);

    try {
      final api = ref.read(productApiProvider);
      final suggestions = await api.getSearchSuggestions(query);
      // Only update if the query hasn't changed
      if (state.query == query) {
        state = state.copyWith(
          suggestions: suggestions,
          isLoadingSuggestions: false,
        );
      }
    } catch (e) {
      if (state.query == query) {
        state = state.copyWith(
          isLoadingSuggestions: false,
          error: e.toString(),
        );
      }
    }
  }

  /// Searches for products with the given query
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) return;

    state = state.copyWith(
      query: query,
      isLoadingResults: true,
      suggestions: [], // Clear suggestions when searching
      clearError: true,
    );

    try {
      final api = ref.read(productApiProvider);
      final results = await api.searchProducts(query);
      state = state.copyWith(results: results, isLoadingResults: false);
    } catch (e) {
      state = state.copyWith(isLoadingResults: false, error: e.toString());
    }
  }

  /// Selects a suggestion and performs search
  Future<void> selectSuggestion(String suggestion) async {
    await searchProducts(suggestion);
  }

  /// Clears the search state
  void clear() {
    state = const SearchState();
  }

  /// Clears only the results (keeps query and suggestions)
  void clearResults() {
    state = state.copyWith(results: []);
  }
}

/// Provider for the SearchController
final searchControllerProvider =
    NotifierProvider<SearchController, SearchState>(SearchController.new);
