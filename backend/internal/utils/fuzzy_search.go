package utils

import (
	"sort"
	"strings"
	"unicode"
)

// FuzzyMatch represents a fuzzy matching result.
type FuzzyMatch struct {
	Text     string
	Distance int
	Score    float64 // 1.0 = exact match, lower = worse match
}

// LevenshteinDistance calculates the minimum number of single-character edits
// (insertions, deletions, substitutions) needed to change one string to another.
func LevenshteinDistance(s1, s2 string) int {
	s1 = strings.ToLower(strings.TrimSpace(s1))
	s2 = strings.ToLower(strings.TrimSpace(s2))

	if s1 == s2 {
		return 0
	}
	if len(s1) == 0 {
		return len(s2)
	}
	if len(s2) == 0 {
		return len(s1)
	}

	// Use two rows instead of full matrix for efficiency
	r1 := []rune(s1)
	r2 := []rune(s2)
	len1 := len(r1)
	len2 := len(r2)

	// Create two work vectors
	prev := make([]int, len2+1)
	curr := make([]int, len2+1)

	// Initialize first row
	for j := 0; j <= len2; j++ {
		prev[j] = j
	}

	for i := 1; i <= len1; i++ {
		curr[0] = i
		for j := 1; j <= len2; j++ {
			cost := 1
			if r1[i-1] == r2[j-1] {
				cost = 0
			}
			curr[j] = min(
				prev[j]+1,      // deletion
				curr[j-1]+1,    // insertion
				prev[j-1]+cost, // substitution
			)
		}
		prev, curr = curr, prev
	}

	return prev[len2]
}

// DamerauLevenshteinDistance is like Levenshtein but also allows transpositions.
// This is better for typos like "teh" -> "the".
func DamerauLevenshteinDistance(s1, s2 string) int {
	s1 = strings.ToLower(strings.TrimSpace(s1))
	s2 = strings.ToLower(strings.TrimSpace(s2))

	if s1 == s2 {
		return 0
	}
	if len(s1) == 0 {
		return len(s2)
	}
	if len(s2) == 0 {
		return len(s1)
	}

	r1 := []rune(s1)
	r2 := []rune(s2)
	len1 := len(r1)
	len2 := len(r2)

	// Create matrix
	d := make([][]int, len1+1)
	for i := range d {
		d[i] = make([]int, len2+1)
	}

	for i := 0; i <= len1; i++ {
		d[i][0] = i
	}
	for j := 0; j <= len2; j++ {
		d[0][j] = j
	}

	for i := 1; i <= len1; i++ {
		for j := 1; j <= len2; j++ {
			cost := 1
			if r1[i-1] == r2[j-1] {
				cost = 0
			}

			d[i][j] = min(
				d[i-1][j]+1,      // deletion
				d[i][j-1]+1,      // insertion
				d[i-1][j-1]+cost, // substitution
			)

			// Transposition
			if i > 1 && j > 1 && r1[i-1] == r2[j-2] && r1[i-2] == r2[j-1] {
				d[i][j] = min(d[i][j], d[i-2][j-2]+cost)
			}
		}
	}

	return d[len1][len2]
}

// FuzzySearch finds targets that fuzzy-match the query within maxDistance.
// Returns matches sorted by relevance (exact matches first, then by distance).
func FuzzySearch(query string, targets []string, maxDistance int) []FuzzyMatch {
	query = strings.ToLower(strings.TrimSpace(query))
	if query == "" {
		return nil
	}

	// Auto-adjust max distance based on query length
	if maxDistance <= 0 {
		maxDistance = getDefaultMaxDistance(len(query))
	}

	var matches []FuzzyMatch

	for _, target := range targets {
		targetLower := strings.ToLower(strings.TrimSpace(target))

		// Check if query is a substring (prefix match is important for autocomplete)
		if strings.Contains(targetLower, query) {
			matches = append(matches, FuzzyMatch{
				Text:     target,
				Distance: 0,
				Score:    1.0,
			})
			continue
		}

		// Calculate edit distance
		dist := DamerauLevenshteinDistance(query, targetLower)
		if dist <= maxDistance {
			// Score decreases with distance
			score := 1.0 - float64(dist)/float64(max(len(query), len(targetLower)))
			matches = append(matches, FuzzyMatch{
				Text:     target,
				Distance: dist,
				Score:    score,
			})
			continue
		}

		// Also check word-by-word matching for multi-word targets
		targetWords := strings.Fields(targetLower)
		for _, word := range targetWords {
			if strings.HasPrefix(word, query) {
				matches = append(matches, FuzzyMatch{
					Text:     target,
					Distance: 0,
					Score:    0.95, // Slightly lower than exact match
				})
				break
			}
			wordDist := DamerauLevenshteinDistance(query, word)
			if wordDist <= maxDistance {
				score := 0.8 * (1.0 - float64(wordDist)/float64(max(len(query), len(word))))
				matches = append(matches, FuzzyMatch{
					Text:     target,
					Distance: wordDist,
					Score:    score,
				})
				break
			}
		}
	}

	// Sort by score (highest first), then by distance (lowest first)
	sort.Slice(matches, func(i, j int) bool {
		if matches[i].Score != matches[j].Score {
			return matches[i].Score > matches[j].Score
		}
		return matches[i].Distance < matches[j].Distance
	})

	return matches
}

// FuzzySearchProducts searches product names with fuzzy matching.
// Returns unique product names that match the query.
func FuzzySearchProducts(query string, productNames []string, limit int) []string {
	if limit <= 0 {
		limit = 10
	}

	matches := FuzzySearch(query, productNames, 0) // Auto max distance

	// Deduplicate and limit
	seen := make(map[string]bool)
	var results []string
	for _, m := range matches {
		normalized := strings.ToLower(m.Text)
		if !seen[normalized] {
			seen[normalized] = true
			results = append(results, m.Text)
			if len(results) >= limit {
				break
			}
		}
	}

	return results
}

// getDefaultMaxDistance returns an appropriate max edit distance for the query length.
func getDefaultMaxDistance(queryLen int) int {
	switch {
	case queryLen <= 2:
		return 0 // No typos for very short queries
	case queryLen <= 4:
		return 1 // Allow 1 typo
	case queryLen <= 8:
		return 2 // Allow 2 typos
	default:
		return 3 // Allow 3 typos for longer queries
	}
}

// NormalizeSearchQuery cleans up a search query for better matching.
func NormalizeSearchQuery(query string) string {
	query = strings.ToLower(strings.TrimSpace(query))

	// Remove extra whitespace
	var result strings.Builder
	prevSpace := false
	for _, r := range query {
		if unicode.IsSpace(r) {
			if !prevSpace {
				result.WriteRune(' ')
				prevSpace = true
			}
		} else {
			result.WriteRune(r)
			prevSpace = false
		}
	}

	return strings.TrimSpace(result.String())
}

func min(nums ...int) int {
	m := nums[0]
	for _, n := range nums[1:] {
		if n < m {
			m = n
		}
	}
	return m
}

func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}
