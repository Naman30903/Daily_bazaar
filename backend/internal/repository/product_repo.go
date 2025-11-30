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

func (r *ProductRepository) GetAllProducts(params *models.ProductSearchParams) ([]models.Product, error) {
	urlStr := fmt.Sprintf("%s/rest/v1/products?select=*", r.baseURL)

	// Add filters
	if params != nil {
		if params.ActiveOnly {
			urlStr += "&active=eq.true"
		}
		if params.CategoryID != "" {
			urlStr += fmt.Sprintf("&category_id=eq.%s", params.CategoryID)
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

	var products []models.Product
	if err := json.NewDecoder(resp.Body).Decode(&products); err != nil {
		return nil, err
	}

	return products, nil
}

func (r *ProductRepository) GetProductByID(id string) (*models.Product, error) {
	urlStr := fmt.Sprintf("%s/rest/v1/products?id=eq.%s", r.baseURL, id)

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

	var products []models.Product
	if err := json.NewDecoder(resp.Body).Decode(&products); err != nil {
		return nil, err
	}

	if len(products) == 0 {
		return nil, errors.New("product not found")
	}

	return &products[0], nil
}

func (r *ProductRepository) GetProductsByCategory(categoryID string) ([]models.Product, error) {
	urlStr := fmt.Sprintf("%s/rest/v1/products?category_id=eq.%s&active=eq.true&order=created_at.desc", r.baseURL, categoryID)

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

	var products []models.Product
	if err := json.NewDecoder(resp.Body).Decode(&products); err != nil {
		return nil, err
	}

	return products, nil
}

func (r *ProductRepository) SearchProducts(query string) ([]models.Product, error) {
	// Use ilike for case-insensitive partial matching
	encodedQuery := url.QueryEscape("%" + query + "%")
	urlStr := fmt.Sprintf("%s/rest/v1/products?or=(name.ilike.%s,description.ilike.%s)&active=eq.true&order=created_at.desc",
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

	var products []models.Product
	if err := json.NewDecoder(resp.Body).Decode(&products); err != nil {
		return nil, err
	}

	return products, nil
}

func (r *ProductRepository) CreateProduct(product *models.Product) error {
	urlStr := fmt.Sprintf("%s/rest/v1/products", r.baseURL)

	body, err := json.Marshal(product)
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

	return &products[0], nil
}

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

func (r *ProductRepository) setHeaders(req *http.Request) {
	req.Header.Set("Authorization", "Bearer "+r.apiKey)
	req.Header.Set("apikey", r.apiKey)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
}
