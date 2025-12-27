package repository

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"

	"github.com/namanjain.3009/daily_bazaar/internal/models"
)

type ProductRepository struct {
	baseURL    string
	apiKey     string
	httpClient *http.Client
}

func NewProductRepository() *ProductRepository {
	return &ProductRepository{
		baseURL:    os.Getenv("SUPABASE_URL"),
		apiKey:     os.Getenv("SUPABASE_KEY"),
		httpClient: &http.Client{Timeout: 10 * time.Second},
	}
}

// CreateProduct inserts product WITHOUT categories
func (r *ProductRepository) CreateProduct(product *models.Product) error {
	urlStr := fmt.Sprintf("%s/rest/v1/products", r.baseURL)

	// Build product data WITHOUT category_id
	productData := map[string]interface{}{
		"id":          product.ID,
		"name":        product.Name,
		"description": product.Description,
		"sku":         product.SKU,
		"price_cents": product.PriceCents,
		"stock":       product.Stock,
		"active":      product.Active,
		"created_at":  product.CreatedAt,
		"metadata":    product.Metadata,
	}

	body, err := json.Marshal(productData)
	if err != nil {
		return err
	}

	req, err := http.NewRequest(http.MethodPost, urlStr, bytes.NewBuffer(body))
	if err != nil {
		return err
	}

	r.setHeaders(req)
	req.Header.Set("Prefer", "return=representation")

	resp, err := r.httpClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)

	if resp.StatusCode != http.StatusCreated {
		return fmt.Errorf("failed to create product: status %d, body: %s", resp.StatusCode, string(respBody))
	}

	var products []models.Product
	if err := json.Unmarshal(respBody, &products); err != nil {
		return fmt.Errorf("failed to decode response: %v", err)
	}

	if len(products) > 0 {
		*product = products[0]
	}

	return nil
}

// LinkProductCategories inserts mappings into product_categories
func (r *ProductRepository) LinkProductCategories(productID string, categoryIDs []string) error {
	if len(categoryIDs) == 0 {
		return nil
	}

	urlStr := fmt.Sprintf("%s/rest/v1/product_categories", r.baseURL)

	// Build batch insert
	mappings := make([]map[string]interface{}, 0, len(categoryIDs))
	for _, catID := range categoryIDs {
		mappings = append(mappings, map[string]interface{}{
			"product_id":  productID,
			"category_id": catID,
		})
	}

	body, err := json.Marshal(mappings)
	if err != nil {
		return err
	}

	req, err := http.NewRequest(http.MethodPost, urlStr, bytes.NewBuffer(body))
	if err != nil {
		return err
	}

	r.setHeaders(req)

	resp, err := r.httpClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)

	if resp.StatusCode != http.StatusCreated {
		return fmt.Errorf("failed to link categories: status %d, body: %s", resp.StatusCode, string(respBody))
	}

	return nil
}

// UnlinkAllProductCategories removes all category mappings for a product
func (r *ProductRepository) UnlinkAllProductCategories(productID string) error {
	urlStr := fmt.Sprintf("%s/rest/v1/product_categories?product_id=eq.%s", r.baseURL, productID)

	req, err := http.NewRequest(http.MethodDelete, urlStr, nil)
	if err != nil {
		return err
	}

	r.setHeaders(req)

	resp, err := r.httpClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusNoContent && resp.StatusCode != http.StatusOK {
		respBody, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("failed to unlink categories: status %d, body: %s", resp.StatusCode, string(respBody))
	}

	return nil
}

// GetProductByID fetches product WITH categories using JOIN
func (r *ProductRepository) GetProductByID(id string) (*models.Product, error) {
	// Supabase REST API: select with embedded categories
	urlStr := fmt.Sprintf("%s/rest/v1/products?id=eq.%s&select=*,categories:product_categories(category_id,categories(id,name,slug,position))", r.baseURL, id)

	req, err := http.NewRequest(http.MethodGet, urlStr, nil)
	if err != nil {
		return nil, err
	}

	r.setHeaders(req)

	resp, err := r.httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var rawProducts []map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&rawProducts); err != nil {
		return nil, err
	}

	if len(rawProducts) == 0 {
		return nil, errors.New("product not found")
	}

	product, err := r.parseProductWithCategories(rawProducts[0])
	if err != nil {
		return nil, err
	}

	return product, nil
}

// GetAllProducts fetches products WITH optional category filter
func (r *ProductRepository) GetAllProducts(params *models.ProductSearchParams) ([]models.Product, error) {
	urlStr := fmt.Sprintf("%s/rest/v1/products?select=*,categories:product_categories(category_id,categories(id,name,slug,position))", r.baseURL)

	// Add filters
	if params != nil {
		if params.ActiveOnly {
			urlStr += "&active=eq.true"
		}

		// NEW: Filter by multiple categories (products that have ANY of these categories)
		if len(params.CategoryIDs) > 0 {
			// We need to join with product_categories and filter
			// Supabase syntax: product_categories.category_id.in.(uuid1,uuid2)
			categoryFilter := strings.Join(params.CategoryIDs, ",")
			urlStr = fmt.Sprintf("%s/rest/v1/products?select=*,product_categories!inner(category_id,categories(id,name,slug,position))", r.baseURL)
			urlStr += fmt.Sprintf("&product_categories.category_id=in.(%s)", categoryFilter)
			if params.ActiveOnly {
				urlStr += "&active=eq.true"
			}
		}

		if params.Limit > 0 {
			urlStr += fmt.Sprintf("&limit=%d", params.Limit)
		}
		if params.Offset > 0 {
			urlStr += fmt.Sprintf("&offset=%d", params.Offset)
		}
	}

	urlStr += "&order=created_at.desc"

	req, err := http.NewRequest(http.MethodGet, urlStr, nil)
	if err != nil {
		return nil, err
	}

	r.setHeaders(req)

	resp, err := r.httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var rawProducts []map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&rawProducts); err != nil {
		return nil, err
	}

	products := make([]models.Product, 0, len(rawProducts))
	for _, raw := range rawProducts {
		product, err := r.parseProductWithCategories(raw)
		if err != nil {
			continue
		}
		products = append(products, *product)
	}

	return products, nil
}

// SearchProducts searches by name/description WITH categories
func (r *ProductRepository) SearchProducts(query string) ([]models.Product, error) {
	encodedQuery := url.QueryEscape("%" + query + "%")
	urlStr := fmt.Sprintf("%s/rest/v1/products?or=(name.ilike.%s,description.ilike.%s)&active=eq.true&select=*,categories:product_categories(category_id,categories(id,name,slug,position))&order=created_at.desc",
		r.baseURL, encodedQuery, encodedQuery)

	req, err := http.NewRequest(http.MethodGet, urlStr, nil)
	if err != nil {
		return nil, err
	}

	r.setHeaders(req)

	resp, err := r.httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var rawProducts []map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&rawProducts); err != nil {
		return nil, err
	}

	products := make([]models.Product, 0, len(rawProducts))
	for _, raw := range rawProducts {
		product, err := r.parseProductWithCategories(raw)
		if err != nil {
			continue
		}
		products = append(products, *product)
	}

	return products, nil
}

// UpdateProduct updates product fields (NOT categories - use LinkProductCategories separately)
func (r *ProductRepository) UpdateProduct(id string, updates map[string]interface{}) (*models.Product, error) {
	urlStr := fmt.Sprintf("%s/rest/v1/products?id=eq.%s", r.baseURL, id)

	body, err := json.Marshal(updates)
	if err != nil {
		return nil, err
	}

	req, err := http.NewRequest(http.MethodPatch, urlStr, bytes.NewBuffer(body))
	if err != nil {
		return nil, err
	}

	r.setHeaders(req)
	req.Header.Set("Prefer", "return=representation")

	resp, err := r.httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("failed to update product: status %d, body: %s", resp.StatusCode, string(respBody))
	}

	var products []models.Product
	if err := json.Unmarshal(respBody, &products); err != nil {
		return nil, fmt.Errorf("failed to decode response: %v", err)
	}

	if len(products) == 0 {
		return nil, errors.New("product not found")
	}

	// Re-fetch to get categories
	return r.GetProductByID(id)
}

// DeleteProduct deletes product (cascade will remove product_categories)
func (r *ProductRepository) DeleteProduct(id string) error {
	urlStr := fmt.Sprintf("%s/rest/v1/products?id=eq.%s", r.baseURL, id)

	req, err := http.NewRequest(http.MethodDelete, urlStr, nil)
	if err != nil {
		return err
	}

	r.setHeaders(req)

	resp, err := r.httpClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusNoContent && resp.StatusCode != http.StatusOK {
		respBody, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("failed to delete product: status %d, body: %s", resp.StatusCode, string(respBody))
	}

	return nil
}

// Helper: parse nested Supabase response with categories
func (r *ProductRepository) parseProductWithCategories(raw map[string]interface{}) (*models.Product, error) {
	product := &models.Product{
		ID:          getString(raw, "id"),
		Name:        getString(raw, "name"),
		Description: getString(raw, "description"),
		SKU:         getString(raw, "sku"),
		PriceCents:  getInt64(raw, "price_cents"),
		Stock:       getInt(raw, "stock"),
		Active:      getBool(raw, "active"),
		CreatedAt:   getTime(raw, "created_at"),
	}

	if metadata, ok := raw["metadata"].(map[string]interface{}); ok {
		product.Metadata = metadata
	}

	// Parse nested categories
	if categoriesRaw, ok := raw["categories"].([]interface{}); ok {
		product.Categories = make([]models.Category, 0, len(categoriesRaw))
		for _, catRaw := range categoriesRaw {
			if catMap, ok := catRaw.(map[string]interface{}); ok {
				if categoryData, ok := catMap["categories"].(map[string]interface{}); ok {
					product.Categories = append(product.Categories, models.Category{
						ID:       getString(categoryData, "id"),
						Name:     getString(categoryData, "name"),
						Slug:     getString(categoryData, "slug"),
						Position: getInt(categoryData, "position"),
					})
				}
			}
		}
	}

	return product, nil
}

func (r *ProductRepository) setHeaders(req *http.Request) {
	req.Header.Set("Authorization", "Bearer "+r.apiKey)
	req.Header.Set("apikey", r.apiKey)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
}

// Helper functions for type assertions
func getString(m map[string]interface{}, key string) string {
	if v, ok := m[key].(string); ok {
		return v
	}
	return ""
}

func getInt(m map[string]interface{}, key string) int {
	if v, ok := m[key].(float64); ok {
		return int(v)
	}
	return 0
}

func getInt64(m map[string]interface{}, key string) int64 {
	if v, ok := m[key].(float64); ok {
		return int64(v)
	}
	return 0
}

func getBool(m map[string]interface{}, key string) bool {
	if v, ok := m[key].(bool); ok {
		return v
	}
	return false
}

func getTime(m map[string]interface{}, key string) time.Time {
	if v, ok := m[key].(string); ok {
		t, _ := time.Parse(time.RFC3339, v)
		return t
	}
	return time.Time{}
}
