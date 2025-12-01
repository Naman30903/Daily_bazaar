package models

import "time"

type Order struct {
	ID              string                 `json:"id"`
	UserID          string                 `json:"user_id,omitempty"`
	SubtotalCents   int64                  `json:"subtotal_cents"`
	ShippingCents   int64                  `json:"shipping_cents"`
	TaxCents        int64                  `json:"tax_cents"`
	TotalCents      int64                  `json:"total_cents"`
	Status          string                 `json:"status"`
	PlacedAt        time.Time              `json:"placed_at"`
	ShippingAddress map[string]interface{} `json:"shipping_address,omitempty"`
	PaymentMetadata map[string]interface{} `json:"payment_metadata,omitempty"`
	Items           []OrderItem            `json:"items,omitempty"`
}

type OrderItem struct {
	ID             string `json:"id"`
	OrderID        string `json:"order_id"`
	ProductID      string `json:"product_id"`
	Quantity       int    `json:"quantity"`
	UnitPriceCents int64  `json:"unit_price_cents"`
}

type CreateOrderRequest struct {
	ShippingAddress map[string]interface{} `json:"shipping_address"`
	PaymentMetadata map[string]interface{} `json:"payment_metadata,omitempty"`
	Items           []CreateOrderItem      `json:"items"`
}

type CreateOrderItem struct {
	ProductID string `json:"product_id"`
	Quantity  int    `json:"quantity"`
}

type UpdateOrderStatus struct {
	Status string `json:"status"`
}

// Order statuses
const (
	OrderStatusPending    = "pending"
	OrderStatusConfirmed  = "confirmed"
	OrderStatusProcessing = "processing"
	OrderStatusShipped    = "shipped"
	OrderStatusDelivered  = "delivered"
	OrderStatusCancelled  = "cancelled"
)
