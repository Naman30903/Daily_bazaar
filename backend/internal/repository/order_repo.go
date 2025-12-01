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

type OrderRepository struct {
	baseURL    string
	apiKey     string
	httpClient *http.Client
}

func NewOrderRepository() *OrderRepository {
	return &OrderRepository{
		baseURL:    os.Getenv("SUPABASE_URL"),
		apiKey:     os.Getenv("SUPABASE_KEY"),
		httpClient: &http.Client{Timeout: 10 * time.Second},
	}
}

func (r *OrderRepository) CreateOrder(order *models.Order) error {
	urlStr := fmt.Sprintf("%s/rest/v1/orders", r.baseURL)

	// Create order without items for DB insertion
	orderData := map[string]interface{}{
		"id":               order.ID,
		"user_id":          order.UserID,
		"subtotal_cents":   order.SubtotalCents,
		"shipping_cents":   order.ShippingCents,
		"tax_cents":        order.TaxCents,
		"total_cents":      order.TotalCents,
		"status":           order.Status,
		"shipping_address": order.ShippingAddress,
		"payment_metadata": order.PaymentMetadata,
	}

	body, err := json.Marshal(orderData)
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
		return fmt.Errorf("failed to create order: status %d, body: %s", resp.StatusCode, string(respBody))
	}

	var orders []models.Order
	if err := json.Unmarshal(respBody, &orders); err != nil {
		return fmt.Errorf("failed to decode response: %v", err)
	}

	if len(orders) > 0 {
		order.ID = orders[0].ID
		order.PlacedAt = orders[0].PlacedAt
	}

	return nil
}

func (r *OrderRepository) CreateOrderItems(items []models.OrderItem) error {
	if len(items) == 0 {
		return nil
	}

	urlStr := fmt.Sprintf("%s/rest/v1/order_items", r.baseURL)

	body, err := json.Marshal(items)
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
		return fmt.Errorf("failed to create order items: status %d, body: %s", resp.StatusCode, string(respBody))
	}

	return nil
}

func (r *OrderRepository) GetOrderByID(id string) (*models.Order, error) {
	urlStr := fmt.Sprintf("%s/rest/v1/orders?id=eq.%s", r.baseURL, id)

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

	var orders []models.Order
	if err := json.NewDecoder(resp.Body).Decode(&orders); err != nil {
		return nil, err
	}

	if len(orders) == 0 {
		return nil, errors.New("order not found")
	}

	// Fetch order items
	items, err := r.GetOrderItems(id)
	if err == nil {
		orders[0].Items = items
	}

	return &orders[0], nil
}

func (r *OrderRepository) GetOrderItems(orderID string) ([]models.OrderItem, error) {
	urlStr := fmt.Sprintf("%s/rest/v1/order_items?order_id=eq.%s", r.baseURL, orderID)

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

	var items []models.OrderItem
	if err := json.NewDecoder(resp.Body).Decode(&items); err != nil {
		return nil, err
	}

	return items, nil
}

func (r *OrderRepository) GetOrdersByUserID(userID string) ([]models.Order, error) {
	urlStr := fmt.Sprintf("%s/rest/v1/orders?user_id=eq.%s&order=placed_at.desc", r.baseURL, userID)

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

	var orders []models.Order
	if err := json.NewDecoder(resp.Body).Decode(&orders); err != nil {
		return nil, err
	}

	// Fetch items for each order
	for i := range orders {
		items, err := r.GetOrderItems(orders[i].ID)
		if err == nil {
			orders[i].Items = items
		}
	}

	return orders, nil
}

func (r *OrderRepository) GetAllOrders(status string, limit, offset int) ([]models.Order, error) {
	urlStr := fmt.Sprintf("%s/rest/v1/orders?select=*&order=placed_at.desc", r.baseURL)

	if status != "" {
		urlStr += fmt.Sprintf("&status=eq.%s", status)
	}
	if limit > 0 {
		urlStr += fmt.Sprintf("&limit=%d", limit)
	}
	if offset > 0 {
		urlStr += fmt.Sprintf("&offset=%d", offset)
	}

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

	var orders []models.Order
	if err := json.NewDecoder(resp.Body).Decode(&orders); err != nil {
		return nil, err
	}

	// Fetch items for each order
	for i := range orders {
		items, err := r.GetOrderItems(orders[i].ID)
		if err == nil {
			orders[i].Items = items
		}
	}

	return orders, nil
}

func (r *OrderRepository) UpdateOrderStatus(id string, status string) (*models.Order, error) {
	urlStr := fmt.Sprintf("%s/rest/v1/orders?id=eq.%s", r.baseURL, id)

	updates := map[string]interface{}{
		"status": status,
	}

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
		return nil, fmt.Errorf("failed to update order: status %d, body: %s", resp.StatusCode, string(respBody))
	}

	var orders []models.Order
	if err := json.Unmarshal(respBody, &orders); err != nil {
		return nil, fmt.Errorf("failed to decode response: %v", err)
	}

	if len(orders) == 0 {
		return nil, errors.New("order not found")
	}

	// Fetch order items
	items, err := r.GetOrderItems(id)
	if err == nil {
		orders[0].Items = items
	}

	return &orders[0], nil
}

func (r *OrderRepository) DeleteOrder(id string) error {
	// First delete order items
	itemsURL := fmt.Sprintf("%s/rest/v1/order_items?order_id=eq.%s", r.baseURL, id)
	req, err := http.NewRequest(http.MethodDelete, itemsURL, nil)
	if err != nil {
		return err
	}
	r.setHeaders(req)
	resp, err := r.httpClient.Do(req)
	if err != nil {
		return err
	}
	resp.Body.Close()

	// Then delete the order
	orderURL := fmt.Sprintf("%s/rest/v1/orders?id=eq.%s", r.baseURL, id)
	req, err = http.NewRequest(http.MethodDelete, orderURL, nil)
	if err != nil {
		return err
	}

	r.setHeaders(req)

	resp, err = r.httpClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusNoContent && resp.StatusCode != http.StatusOK {
		respBody, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("failed to delete order: status %d, body: %s", resp.StatusCode, string(respBody))
	}

	return nil
}

func (r *OrderRepository) setHeaders(req *http.Request) {
	req.Header.Set("Authorization", "Bearer "+r.apiKey)
	req.Header.Set("apikey", r.apiKey)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
}
