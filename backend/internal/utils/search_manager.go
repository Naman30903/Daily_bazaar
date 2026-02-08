package utils

import (
	"sync"
)

// SearchManager coordinates bloom filter and fuzzy search for products.
// It should be initialized once at application startup and refreshed periodically.
type SearchManager struct {
	filter       *ProductSearchFilter
	productNames []string
	mu           sync.RWMutex
}

// Global instance
var globalSearchManager *SearchManager
var searchManagerOnce sync.Once

// GetSearchManager returns the global search manager instance.
func GetSearchManager() *SearchManager {
	searchManagerOnce.Do(func() {
		globalSearchManager = &SearchManager{
			filter:       NewProductSearchFilter(1000),
			productNames: make([]string, 0),
		}
	})
	return globalSearchManager
}

// Initialize sets up the search manager with product names.
func (sm *SearchManager) Initialize(productNames []string) {
	sm.mu.Lock()
	defer sm.mu.Unlock()

	sm.productNames = make([]string, len(productNames))
	copy(sm.productNames, productNames)

	sm.filter = NewProductSearchFilter(len(productNames))
	sm.filter.AddProducts(productNames)
}

// AddProduct adds a new product name to the index.
func (sm *SearchManager) AddProduct(name string) {
	sm.mu.Lock()
	defer sm.mu.Unlock()

	sm.productNames = append(sm.productNames, name)
	sm.filter.AddProduct(name)
}

// MayMatch checks if a query might match any product.
func (sm *SearchManager) MayMatch(query string) bool {
	sm.mu.RLock()
	defer sm.mu.RUnlock()

	return sm.filter.MayMatch(query)
}

// GetSuggestions returns fuzzy-matched product names for autocomplete.
func (sm *SearchManager) GetSuggestions(query string, limit int) []string {
	sm.mu.RLock()
	names := make([]string, len(sm.productNames))
	copy(names, sm.productNames)
	sm.mu.RUnlock()

	return FuzzySearchProducts(query, names, limit)
}

// GetProductNames returns all indexed product names.
func (sm *SearchManager) GetProductNames() []string {
	sm.mu.RLock()
	defer sm.mu.RUnlock()

	result := make([]string, len(sm.productNames))
	copy(result, sm.productNames)
	return result
}

// Clear resets the search manager.
func (sm *SearchManager) Clear() {
	sm.mu.Lock()
	defer sm.mu.Unlock()

	sm.productNames = make([]string, 0)
	sm.filter.Clear()
}
