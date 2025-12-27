package models

import "time"

type Product struct {
	ID          string                 `json:"id"`
	Name        string                 `json:"name"`
	Description string                 `json:"description,omitempty"`
	SKU         string                 `json:"sku,omitempty"`
	PriceCents  int64                  `json:"price_cents"`
	Stock       int                    `json:"stock"`
	Active      bool                   `json:"active"`
	CreatedAt   time.Time              `json:"created_at"`
	Metadata    map[string]interface{} `json:"metadata,omitempty"`

	// NEW: replaced single category_id with array
	Categories []Category `json:"categories,omitempty"`
}

type AddProduct struct {
	Name        string                 `json:"name"`
	Description string                 `json:"description,omitempty"`
	SKU         string                 `json:"sku,omitempty"`
	PriceCents  int64                  `json:"price_cents"`
	Stock       int                    `json:"stock"`
	Active      bool                   `json:"active"`
	CategoryIDs []string               `json:"category_ids"` // NEW: multiple categories
	Metadata    map[string]interface{} `json:"metadata,omitempty"`
}

type UpdateProduct struct {
	Name        *string                `json:"name,omitempty"`
	Description *string                `json:"description,omitempty"`
	SKU         *string                `json:"sku,omitempty"`
	PriceCents  *int64                 `json:"price_cents,omitempty"`
	Stock       *int                   `json:"stock,omitempty"`
	Active      *bool                  `json:"active,omitempty"`
	CategoryIDs []string               `json:"category_ids,omitempty"` // NEW: replace categories
	Metadata    map[string]interface{} `json:"metadata,omitempty"`
}

type ProductSearchParams struct {
	Query       string   `json:"query,omitempty"`
	CategoryIDs []string `json:"category_ids,omitempty"` // NEW: filter by multiple categories
	ActiveOnly  bool     `json:"active_only,omitempty"`
	Limit       int      `json:"limit,omitempty"`
	Offset      int      `json:"offset,omitempty"`
}

type ProductImage struct {
	ID        string `json:"id"`
	ProductID string `json:"product_id"`
	URL       string `json:"url"`
	Position  int    `json:"position"`
}

type AddProductImage struct {
	ProductID string `json:"product_id"`
	URL       string `json:"url"`
	Position  int    `json:"position"`
}

type UpdateProductImage struct {
	URL      *string `json:"url,omitempty"`
	Position *int    `json:"position,omitempty"`
}

type ReorderProductImages struct {
	ImageIDs []string `json:"image_ids"` // IDs in desired order
}
