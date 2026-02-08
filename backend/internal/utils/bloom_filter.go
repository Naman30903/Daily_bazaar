package utils

import (
	"hash/fnv"
	"strings"
	"sync"
)

// BloomFilter is a probabilistic data structure for fast membership testing.
// It may return false positives, but never false negatives.
type BloomFilter struct {
	bitset    []bool
	size      uint64
	hashCount uint64
	mu        sync.RWMutex
}

// NewBloomFilter creates a new bloom filter with the given size and number of hash functions.
// For n expected items with false positive rate p:
// size = -n*ln(p) / (ln(2)^2)
// hashCount = (size/n) * ln(2)
func NewBloomFilter(size, hashCount uint64) *BloomFilter {
	return &BloomFilter{
		bitset:    make([]bool, size),
		size:      size,
		hashCount: hashCount,
	}
}

// NewBloomFilterForItems creates an optimized bloom filter for n items with ~1% false positive rate.
func NewBloomFilterForItems(n int) *BloomFilter {
	if n <= 0 {
		n = 1000 // default
	}
	// For 1% false positive rate: size ≈ 9.6n, hashCount ≈ 7
	size := uint64(float64(n) * 9.6)
	hashCount := uint64(7)
	return NewBloomFilter(size, hashCount)
}

// Add inserts an item into the bloom filter.
func (bf *BloomFilter) Add(item string) {
	bf.mu.Lock()
	defer bf.mu.Unlock()

	item = strings.ToLower(strings.TrimSpace(item))
	for i := uint64(0); i < bf.hashCount; i++ {
		pos := bf.hash(item, i) % bf.size
		bf.bitset[pos] = true
	}
}

// AddMultiple inserts multiple items into the bloom filter.
func (bf *BloomFilter) AddMultiple(items []string) {
	bf.mu.Lock()
	defer bf.mu.Unlock()

	for _, item := range items {
		item = strings.ToLower(strings.TrimSpace(item))
		for i := uint64(0); i < bf.hashCount; i++ {
			pos := bf.hash(item, i) % bf.size
			bf.bitset[pos] = true
		}
	}
}

// MayContain checks if an item might be in the set.
// Returns true if the item might be present (with possible false positive).
// Returns false if the item is definitely not in the set.
func (bf *BloomFilter) MayContain(item string) bool {
	bf.mu.RLock()
	defer bf.mu.RUnlock()

	item = strings.ToLower(strings.TrimSpace(item))
	for i := uint64(0); i < bf.hashCount; i++ {
		pos := bf.hash(item, i) % bf.size
		if !bf.bitset[pos] {
			return false
		}
	}
	return true
}

// MayContainAnyWord checks if any word in the query might match.
// Useful for multi-word searches.
func (bf *BloomFilter) MayContainAnyWord(query string) bool {
	bf.mu.RLock()
	defer bf.mu.RUnlock()

	query = strings.ToLower(strings.TrimSpace(query))
	words := strings.Fields(query)

	// If single word, check directly
	if len(words) == 1 {
		return bf.mayContainWithoutLock(words[0])
	}

	// For multiple words, check if any word might match
	for _, word := range words {
		if len(word) >= 2 && bf.mayContainWithoutLock(word) {
			return true
		}
	}

	return false
}

// mayContainWithoutLock is an internal method that doesn't acquire the lock.
func (bf *BloomFilter) mayContainWithoutLock(item string) bool {
	for i := uint64(0); i < bf.hashCount; i++ {
		pos := bf.hash(item, i) % bf.size
		if !bf.bitset[pos] {
			return false
		}
	}
	return true
}

// Clear resets the bloom filter.
func (bf *BloomFilter) Clear() {
	bf.mu.Lock()
	defer bf.mu.Unlock()

	bf.bitset = make([]bool, bf.size)
}

// hash generates a hash value for the item with a given seed.
func (bf *BloomFilter) hash(item string, seed uint64) uint64 {
	h := fnv.New64a()
	h.Write([]byte(item))
	h.Write([]byte{byte(seed), byte(seed >> 8), byte(seed >> 16), byte(seed >> 24)})
	return h.Sum64()
}

// ProductSearchFilter is a specialized bloom filter for product search.
type ProductSearchFilter struct {
	nameFilter *BloomFilter
	wordFilter *BloomFilter
}

// NewProductSearchFilter creates a new product search filter.
func NewProductSearchFilter(productCount int) *ProductSearchFilter {
	return &ProductSearchFilter{
		nameFilter: NewBloomFilterForItems(productCount),
		wordFilter: NewBloomFilterForItems(productCount * 3), // ~3 words per product name
	}
}

// AddProduct adds a product name and its words to the filter.
func (psf *ProductSearchFilter) AddProduct(name string) {
	name = strings.ToLower(strings.TrimSpace(name))
	psf.nameFilter.Add(name)

	// Also add individual words for partial matching
	words := strings.Fields(name)
	for _, word := range words {
		if len(word) >= 2 {
			psf.wordFilter.Add(word)
		}
	}
}

// AddProducts adds multiple product names to the filter.
func (psf *ProductSearchFilter) AddProducts(names []string) {
	for _, name := range names {
		psf.AddProduct(name)
	}
}

// MayMatch checks if a search query might match any product.
func (psf *ProductSearchFilter) MayMatch(query string) bool {
	query = strings.ToLower(strings.TrimSpace(query))

	// Check if exact name might match
	if psf.nameFilter.MayContain(query) {
		return true
	}

	// Check if any word might match
	words := strings.Fields(query)
	for _, word := range words {
		if len(word) >= 2 && psf.wordFilter.MayContain(word) {
			return true
		}
	}

	return false
}

// Clear resets both filters.
func (psf *ProductSearchFilter) Clear() {
	psf.nameFilter.Clear()
	psf.wordFilter.Clear()
}
