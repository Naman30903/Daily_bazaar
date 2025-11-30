package models

import "time"

type Product struct {
	ID          string                 `json:"id"`
	Name        string                 `json:"name"`
	Description string                 `json:"description,omitempty"`
	SKU         string                 `json:"sku,omitempty"`
	PriceCents  int64                  `json:"price_cents"`
	Stock       int                    `json:"stock"`
	CategoryID  string                 `json:"category_id,omitempty"`
	Active      bool                   `json:"active"`
	CreatedAt   time.Time              `json:"created_at"`
	Metadata    map[string]interface{} `json:"metadata,omitempty"`
}

type AddProduct struct {
	Name        string                 `json:"name"`
	Description string                 `json:"description,omitempty"`
	SKU         string                 `json:"sku,omitempty"`
	PriceCents  int64                  `json:"price_cents"`
	Stock       int                    `json:"stock"`
	CategoryID  string                 `json:"category_id,omitempty"`
	Active      bool                   `json:"active"`
	Metadata    map[string]interface{} `json:"metadata,omitempty"`
}

type UpdateProduct struct {
	Name        *string                `json:"name,omitempty"`
	Description *string                `json:"description,omitempty"`
	SKU         *string                `json:"sku,omitempty"`
	PriceCents  *int64                 `json:"price_cents,omitempty"`
	Stock       *int                   `json:"stock,omitempty"`
	CategoryID  *string                `json:"category_id,omitempty"`
	Active      *bool                  `json:"active,omitempty"`
	Metadata    map[string]interface{} `json:"metadata,omitempty"`
}

type ProductSearchParams struct {
	Query      string `json:"query,omitempty"`
	CategoryID string `json:"category_id,omitempty"`
	ActiveOnly bool   `json:"active_only,omitempty"`
	Limit      int    `json:"limit,omitempty"`
	Offset     int    `json:"offset,omitempty"`
}
