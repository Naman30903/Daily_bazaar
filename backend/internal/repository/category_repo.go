package repository

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"time"

	"github.com/namanjain.3009/daily_bazaar/internal/models"
)

type CategoryRepository struct {
	baseURL    string
	apiKey     string
	httpClient *http.Client
}

func NewCategoryRepository() *CategoryRepository {
	return &CategoryRepository{
		baseURL:    os.Getenv("SUPABASE_URL"),
		apiKey:     os.Getenv("SUPABASE_KEY"),
		httpClient: &http.Client{Timeout: 10 * time.Second},
	}
}

func (r *CategoryRepository) GetAllCategories() ([]models.Category, error) {
	urlStr := fmt.Sprintf("%s/rest/v1/categories?select=*&order=position.asc", r.baseURL)

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

	var categories []models.Category
	if err := json.NewDecoder(resp.Body).Decode(&categories); err != nil {
		return nil, err
	}

	return categories, nil
}

func (r *CategoryRepository) GetCategoryByID(id string) (*models.Category, error) {
	urlStr := fmt.Sprintf("%s/rest/v1/categories?id=eq.%s", r.baseURL, id)

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

	var categories []models.Category
	if err := json.NewDecoder(resp.Body).Decode(&categories); err != nil {
		return nil, err
	}

	if len(categories) == 0 {
		return nil, errors.New("category not found")
	}

	return &categories[0], nil
}

func (r *CategoryRepository) GetCategoryBySlug(slug string) (*models.Category, error) {
	urlStr := fmt.Sprintf("%s/rest/v1/categories?slug=eq.%s", r.baseURL, slug)

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

	var categories []models.Category
	if err := json.NewDecoder(resp.Body).Decode(&categories); err != nil {
		return nil, err
	}

	if len(categories) == 0 {
		return nil, errors.New("category not found")
	}

	return &categories[0], nil
}

func (r *CategoryRepository) GetSubcategories(parentID string) ([]models.Category, error) {
	urlStr := fmt.Sprintf("%s/rest/v1/categories?parent_id=eq.%s&order=position.asc", r.baseURL, parentID)

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

	var categories []models.Category
	if err := json.NewDecoder(resp.Body).Decode(&categories); err != nil {
		return nil, err
	}

	return categories, nil
}

// GetRootCategories fetches root categories with optional position range filter.
func (r *CategoryRepository) GetRootCategories(minPosition, maxPosition *int) ([]models.Category, error) {
	urlStr := fmt.Sprintf("%s/rest/v1/categories?parent_id=is.null", r.baseURL)

	// Optional position range filters
	if minPosition != nil {
		urlStr += fmt.Sprintf("&position=gte.%d", *minPosition)
	}
	if maxPosition != nil {
		urlStr += fmt.Sprintf("&position=lte.%d", *maxPosition)
	}

	urlStr += "&order=position.asc"

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

	var categories []models.Category
	if err := json.NewDecoder(resp.Body).Decode(&categories); err != nil {
		return nil, err
	}

	return categories, nil
}

func (r *CategoryRepository) CreateCategory(category *models.Category) error {
	urlStr := fmt.Sprintf("%s/rest/v1/categories", r.baseURL)

	body, err := json.Marshal(category)
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
		return fmt.Errorf("failed to create category: status %d, body: %s", resp.StatusCode, string(respBody))
	}

	var categories []models.Category
	if err := json.Unmarshal(respBody, &categories); err != nil {
		return fmt.Errorf("failed to decode response: %v", err)
	}

	if len(categories) > 0 {
		*category = categories[0]
	}

	return nil
}

func (r *CategoryRepository) UpdateCategory(id string, updates map[string]interface{}) (*models.Category, error) {
	urlStr := fmt.Sprintf("%s/rest/v1/categories?id=eq.%s", r.baseURL, id)

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
		return nil, fmt.Errorf("failed to update category: status %d, body: %s", resp.StatusCode, string(respBody))
	}

	var categories []models.Category
	if err := json.Unmarshal(respBody, &categories); err != nil {
		return nil, fmt.Errorf("failed to decode response: %v", err)
	}

	if len(categories) == 0 {
		return nil, errors.New("category not found")
	}

	return &categories[0], nil
}

func (r *CategoryRepository) DeleteCategory(id string) error {
	urlStr := fmt.Sprintf("%s/rest/v1/categories?id=eq.%s", r.baseURL, id)

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
		return fmt.Errorf("failed to delete category: status %d, body: %s", resp.StatusCode, string(respBody))
	}

	return nil
}

func (r *CategoryRepository) setHeaders(req *http.Request) {
	req.Header.Set("Authorization", "Bearer "+r.apiKey)
	req.Header.Set("apikey", r.apiKey)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
}
