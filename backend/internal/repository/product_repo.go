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
	// Supabase REST API: select with embedded categories and images
	urlStr := fmt.Sprintf("%s/rest/v1/products?id=eq.%s&select=*,images:product_images(id,url,position),categories:product_categories(category_id,categories(id,name,slug,position)),variants:product_variants(*)", r.baseURL, id)

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
	// Standard select fields
	selectFields := "*,images:product_images(id,url,position),variants:product_variants(*)"

	// Join with product_categories and nested categories
	// We use !inner when filtering by category to force a match
	categoryJoin := "categories:product_categories(category_id,categories(id,name,slug,position))"
	if params != nil && len(params.CategoryIDs) > 0 {
		categoryJoin = "categories:product_categories!inner(category_id,categories(id,name,slug,position))"
	}

	urlStr := fmt.Sprintf("%s/rest/v1/products?select=%s,%s", r.baseURL, selectFields, categoryJoin)

	// Add filters
	if params != nil {
		if params.ActiveOnly {
			urlStr += "&active=eq.true"
		}

		if len(params.CategoryIDs) > 0 {
			categoryFilter := strings.Join(params.CategoryIDs, ",")
			urlStr += fmt.Sprintf("&categories.category_id=in.(%s)", categoryFilter)
		}

		if params.Limit > 0 {
			urlStr += fmt.Sprintf("&limit=%d", params.Limit)
		}
		if params.Offset > 0 {
			urlStr += fmt.Sprintf("&offset=%d", params.Offset)
		}
	}

	urlStr += "&order=created_at.desc"

	fmt.Printf("[DEBUG] GetAllProducts URL: %s\n", urlStr)

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
	urlStr := fmt.Sprintf("%s/rest/v1/products?or=(name.ilike.%s,description.ilike.%s)&active=eq.true&select=*,categories:product_categories(category_id,categories(id,name,slug,position)),variants:product_variants(*)&order=created_at.desc",
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

// GetProductsByCategorySQL fetches products using raw SQL via RPC
// Returns full product data including categories, images, and variants
func (r *ProductRepository) GetProductsByCategorySQL(categoryID string, limit, offset int) ([]models.Product, error) {
	urlStr := fmt.Sprintf("%s/rest/v1/rpc/get_products_by_category", r.baseURL)

	// Build request body for RPC call
	requestBody := map[string]interface{}{
		"p_category_id": categoryID,
		"p_limit":       limit,
		"p_offset":      offset,
	}

	body, err := json.Marshal(requestBody)
	if err != nil {
		return nil, err
	}

	req, err := http.NewRequest(http.MethodPost, urlStr, bytes.NewBuffer(body))
	if err != nil {
		return nil, err
	}

	r.setHeaders(req)

	resp, err := r.httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("RPC call failed: status %d, body: %s", resp.StatusCode, string(respBody))
	}

	// Parse the RPC response with full JSON fields
	var rpcResults []struct {
		ID          string                 `json:"id"`
		Name        string                 `json:"name"`
		Description string                 `json:"description"`
		SKU         string                 `json:"sku"`
		PriceCents  int64                  `json:"price_cents"`
		Stock       int                    `json:"stock"`
		Active      bool                   `json:"active"`
		CreatedAt   time.Time              `json:"created_at"`
		Metadata    map[string]interface{} `json:"metadata"`
		Weight      string                 `json:"weight"`
		Categories  []struct {
			ID       string `json:"id"`
			Name     string `json:"name"`
			Slug     string `json:"slug"`
			Position *int   `json:"position"`
		} `json:"categories"`
		Images []struct {
			ID        string `json:"id"`
			ProductID string `json:"product_id"`
			URL       string `json:"url"`
			Position  int    `json:"position"`
		} `json:"images"`
		Variants []struct {
			ID         string `json:"id"`
			Name       string `json:"name"`
			PriceCents int64  `json:"price_cents"`
			Weight     string `json:"weight"`
		} `json:"variants"`
	}

	if err := json.Unmarshal(respBody, &rpcResults); err != nil {
		return nil, fmt.Errorf("failed to parse RPC response: %v", err)
	}

	// Convert to Product models
	products := make([]models.Product, 0, len(rpcResults))
	for _, row := range rpcResults {
		product := models.Product{
			ID:          row.ID,
			Name:        row.Name,
			Description: row.Description,
			SKU:         row.SKU,
			PriceCents:  row.PriceCents,
			Stock:       row.Stock,
			Active:      row.Active,
			CreatedAt:   row.CreatedAt,
			Metadata:    row.Metadata,
			Weight:      row.Weight,
		}

		// Convert categories
		product.Categories = make([]models.ProductCategory, 0, len(row.Categories))
		for _, cat := range row.Categories {
			product.Categories = append(product.Categories, models.ProductCategory{
				ID:       cat.ID,
				Name:     cat.Name,
				Slug:     cat.Slug,
				Position: cat.Position,
			})
		}

		// Convert images
		product.Images = make([]models.ProductImage, 0, len(row.Images))
		for _, img := range row.Images {
			product.Images = append(product.Images, models.ProductImage{
				ID:        img.ID,
				ProductID: img.ProductID,
				URL:       img.URL,
				Position:  img.Position,
			})
		}

		// Convert variants
		product.Variants = make([]models.ProductVariant, 0, len(row.Variants))
		for _, v := range row.Variants {
			product.Variants = append(product.Variants, models.ProductVariant{
				ID:         v.ID,
				Name:       v.Name,
				PriceCents: v.PriceCents,
				Weight:     v.Weight,
			})
		}

		products = append(products, product)
	}

	return products, nil
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

	// Parse nested categories into ProductCategory (used by Product model)
	if categoriesRaw, ok := raw["categories"].([]interface{}); ok {
		product.Categories = make([]models.ProductCategory, 0, len(categoriesRaw))
		for _, catRaw := range categoriesRaw {
			if catMap, ok := catRaw.(map[string]interface{}); ok {
				if categoryData, ok := catMap["categories"].(map[string]interface{}); ok {
					// Position in ProductCategory is a pointer to int
					var pos *int
					if p, ok := categoryData["position"].(float64); ok {
						pv := int(p)
						pos = &pv
					}

					product.Categories = append(product.Categories, models.ProductCategory{
						ID:       getString(categoryData, "id"),
						Name:     getString(categoryData, "name"),
						Slug:     getString(categoryData, "slug"),
						Position: pos,
					})
				}
			}
		}
	}

	// NEW: Parse images embedded by select into Product.Images
	if imagesRaw, ok := raw["images"].([]interface{}); ok {
		product.Images = make([]models.ProductImage, 0, len(imagesRaw))
		for _, img := range imagesRaw {
			if m, ok := img.(map[string]interface{}); ok {
				pos := 0
				if p, ok := m["position"].(float64); ok {
					pos = int(p)
				}
				product.Images = append(product.Images, models.ProductImage{
					ID:        getString(m, "id"),
					ProductID: product.ID,
					URL:       getString(m, "url"),
					Position:  pos,
				})
			}
		}
	}

	// NEW: Parse variants embedded by select into Product.Variants
	if variantsRaw, ok := raw["variants"].([]interface{}); ok {
		product.Variants = make([]models.ProductVariant, 0, len(variantsRaw))
		for _, v := range variantsRaw {
			if m, ok := v.(map[string]interface{}); ok {
				product.Variants = append(product.Variants, models.ProductVariant{
					ID:         getString(m, "id"),
					Name:       getString(m, "name"),
					PriceCents: getInt64(m, "price_cents"),
					Weight:     getString(m, "weight"),
				})
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
