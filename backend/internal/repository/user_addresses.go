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

type UserAddressRepository struct {
	baseURL    string
	apiKey     string
	httpClient *http.Client
}

func NewUserAddressRepository() *UserAddressRepository {
	return &UserAddressRepository{
		baseURL:    os.Getenv("SUPABASE_URL"),
		apiKey:     os.Getenv("SUPABASE_KEY"),
		httpClient: &http.Client{Timeout: 10 * time.Second},
	}
}

func (r *UserAddressRepository) setHeaders(req *http.Request) {
	req.Header.Set("Authorization", "Bearer "+r.apiKey)
	req.Header.Set("apikey", r.apiKey)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
}

func (r *UserAddressRepository) ListByUserID(userID string) ([]models.UserAddress, error) {
	urlStr := fmt.Sprintf("%s/rest/v1/user_addresses?user_id=eq.%s&order=created_at.desc", r.baseURL, userID)

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

	var out []models.UserAddress
	if err := json.NewDecoder(resp.Body).Decode(&out); err != nil {
		return nil, err
	}
	return out, nil
}

func (r *UserAddressRepository) GetByID(id string) (*models.UserAddress, error) {
	urlStr := fmt.Sprintf("%s/rest/v1/user_addresses?id=eq.%s", r.baseURL, id)

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

	var out []models.UserAddress
	if err := json.NewDecoder(resp.Body).Decode(&out); err != nil {
		return nil, err
	}
	if len(out) == 0 {
		return nil, errors.New("address not found")
	}
	return &out[0], nil
}

func (r *UserAddressRepository) Create(addr *models.UserAddress) error {
	urlStr := fmt.Sprintf("%s/rest/v1/user_addresses", r.baseURL)

	body, err := json.Marshal(addr)
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
		return fmt.Errorf("failed to create address: status %d, body: %s", resp.StatusCode, string(respBody))
	}

	var out []models.UserAddress
	if err := json.Unmarshal(respBody, &out); err != nil {
		return err
	}
	if len(out) > 0 {
		*addr = out[0]
	}
	return nil
}

func (r *UserAddressRepository) Update(id string, updates map[string]interface{}) (*models.UserAddress, error) {
	urlStr := fmt.Sprintf("%s/rest/v1/user_addresses?id=eq.%s", r.baseURL, id)

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
		return nil, fmt.Errorf("failed to update address: status %d, body: %s", resp.StatusCode, string(respBody))
	}

	var out []models.UserAddress
	if err := json.Unmarshal(respBody, &out); err != nil {
		return nil, err
	}
	if len(out) == 0 {
		return nil, errors.New("address not found")
	}
	return &out[0], nil
}

func (r *UserAddressRepository) Delete(id string) error {
	urlStr := fmt.Sprintf("%s/rest/v1/user_addresses?id=eq.%s", r.baseURL, id)

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
		return fmt.Errorf("failed to delete address: status %d, body: %s", resp.StatusCode, string(respBody))
	}
	return nil
}
