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

type UserRepository struct {
	baseURL    string
	apiKey     string
	httpClient *http.Client
}

func NewUserRepository() *UserRepository {
	return &UserRepository{
		baseURL:    os.Getenv("SUPABASE_URL"),
		apiKey:     os.Getenv("SUPABASE_KEY"),
		httpClient: &http.Client{Timeout: 10 * time.Second},
	}
}

func (r *UserRepository) CreateUser(user *models.User) error {
	url := fmt.Sprintf("%s/rest/v1/users", r.baseURL)

	body, err := json.Marshal(user)
	if err != nil {
		return err
	}

	req, err := http.NewRequest(http.MethodPost, url, bytes.NewBuffer(body))
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

	// Read response body for error details
	respBody, _ := io.ReadAll(resp.Body)

	if resp.StatusCode != http.StatusCreated {
		return fmt.Errorf("failed to create user: status %d, body: %s", resp.StatusCode, string(respBody))
	}

	var users []models.User
	if err := json.Unmarshal(respBody, &users); err != nil {
		return fmt.Errorf("failed to decode response: %v, body: %s", err, string(respBody))
	}

	if len(users) > 0 {
		*user = users[0]
	}

	return nil
}

func (r *UserRepository) GetUserByEmail(email string) (*models.User, error) {
	url := fmt.Sprintf("%s/rest/v1/users?email=eq.%s", r.baseURL, email)

	req, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		return nil, err
	}

	r.setHeaders(req)

	resp, err := r.httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var users []models.User
	if err := json.NewDecoder(resp.Body).Decode(&users); err != nil {
		return nil, err
	}

	if len(users) == 0 {
		return nil, errors.New("user not found")
	}

	return &users[0], nil
}

func (r *UserRepository) GetUserByID(id string) (*models.User, error) {
	url := fmt.Sprintf("%s/rest/v1/users?id=eq.%s", r.baseURL, id)

	req, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		return nil, err
	}

	r.setHeaders(req)

	resp, err := r.httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var users []models.User
	if err := json.NewDecoder(resp.Body).Decode(&users); err != nil {
		return nil, err
	}

	if len(users) == 0 {
		return nil, errors.New("user not found")
	}

	return &users[0], nil
}

func (r *UserRepository) UpdateUser(userID string, fields map[string]interface{}) error {
	url := fmt.Sprintf("%s/rest/v1/users?id=eq.%s", r.baseURL, userID)

	body, err := json.Marshal(fields)
	if err != nil {
		return err
	}

	req, err := http.NewRequest(http.MethodPatch, url, bytes.NewBuffer(body))
	if err != nil {
		return err
	}

	r.setHeaders(req)
	req.Header.Set("Prefer", "return=minimal")

	resp, err := r.httpClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusNoContent {
		respBody, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("failed to update user: status %d, body: %s", resp.StatusCode, string(respBody))
	}

	return nil
}

func (r *UserRepository) setHeaders(req *http.Request) {
	req.Header.Set("Authorization", "Bearer "+r.apiKey)
	req.Header.Set("apikey", r.apiKey)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
}
