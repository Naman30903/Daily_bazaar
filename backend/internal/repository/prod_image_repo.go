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

type ProductImageRepository struct {
	baseURL    string
	apiKey     string
	httpClient *http.Client
}

func NewProductImageRepository() *ProductImageRepository {
	return &ProductImageRepository{
		baseURL:    os.Getenv("SUPABASE_URL"),
		apiKey:     os.Getenv("SUPABASE_KEY"),
		httpClient: &http.Client{Timeout: 10 * time.Second},
	}
}

func (r *ProductImageRepository) GetImagesByProductID(productID string) ([]models.ProductImage, error) {
	urlStr := fmt.Sprintf("%s/rest/v1/product_images?product_id=eq.%s&order=position.asc", r.baseURL, productID)

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

	var images []models.ProductImage
	if err := json.NewDecoder(resp.Body).Decode(&images); err != nil {
		return nil, err
	}

	return images, nil
}

func (r *ProductImageRepository) GetImageByID(id string) (*models.ProductImage, error) {
	urlStr := fmt.Sprintf("%s/rest/v1/product_images?id=eq.%s", r.baseURL, id)

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

	var images []models.ProductImage
	if err := json.NewDecoder(resp.Body).Decode(&images); err != nil {
		return nil, err
	}

	if len(images) == 0 {
		return nil, errors.New("image not found")
	}

	return &images[0], nil
}

func (r *ProductImageRepository) CreateImage(image *models.ProductImage) error {
	urlStr := fmt.Sprintf("%s/rest/v1/product_images", r.baseURL)

	body, err := json.Marshal(image)
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
		return fmt.Errorf("failed to create image: status %d, body: %s", resp.StatusCode, string(respBody))
	}

	var images []models.ProductImage
	if err := json.Unmarshal(respBody, &images); err != nil {
		return fmt.Errorf("failed to decode response: %v", err)
	}

	if len(images) > 0 {
		*image = images[0]
	}

	return nil
}

func (r *ProductImageRepository) CreateImages(images []models.ProductImage) error {
	if len(images) == 0 {
		return nil
	}

	urlStr := fmt.Sprintf("%s/rest/v1/product_images", r.baseURL)

	body, err := json.Marshal(images)
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
		return fmt.Errorf("failed to create images: status %d, body: %s", resp.StatusCode, string(respBody))
	}

	return nil
}

func (r *ProductImageRepository) UpdateImage(id string, updates map[string]interface{}) (*models.ProductImage, error) {
	urlStr := fmt.Sprintf("%s/rest/v1/product_images?id=eq.%s", r.baseURL, id)

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
		return nil, fmt.Errorf("failed to update image: status %d, body: %s", resp.StatusCode, string(respBody))
	}

	var images []models.ProductImage
	if err := json.Unmarshal(respBody, &images); err != nil {
		return nil, fmt.Errorf("failed to decode response: %v", err)
	}

	if len(images) == 0 {
		return nil, errors.New("image not found")
	}

	return &images[0], nil
}

func (r *ProductImageRepository) DeleteImage(id string) error {
	urlStr := fmt.Sprintf("%s/rest/v1/product_images?id=eq.%s", r.baseURL, id)

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
		return fmt.Errorf("failed to delete image: status %d, body: %s", resp.StatusCode, string(respBody))
	}

	return nil
}

func (r *ProductImageRepository) DeleteImagesByProductID(productID string) error {
	urlStr := fmt.Sprintf("%s/rest/v1/product_images?product_id=eq.%s", r.baseURL, productID)

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
		return fmt.Errorf("failed to delete images: status %d, body: %s", resp.StatusCode, string(respBody))
	}

	return nil
}

func (r *ProductImageRepository) GetMaxPosition(productID string) (int, error) {
	urlStr := fmt.Sprintf("%s/rest/v1/product_images?product_id=eq.%s&order=position.desc&limit=1", r.baseURL, productID)

	req, err := http.NewRequest(http.MethodGet, urlStr, nil)
	if err != nil {
		return 0, err
	}

	r.setHeaders(req)

	resp, err := r.httpClient.Do(req)
	if err != nil {
		return 0, err
	}
	defer resp.Body.Close()

	var images []models.ProductImage
	if err := json.NewDecoder(resp.Body).Decode(&images); err != nil {
		return 0, err
	}

	if len(images) == 0 {
		return 0, nil
	}

	return images[0].Position, nil
}

func (r *ProductImageRepository) setHeaders(req *http.Request) {
	req.Header.Set("Authorization", "Bearer "+r.apiKey)
	req.Header.Set("apikey", r.apiKey)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
}
