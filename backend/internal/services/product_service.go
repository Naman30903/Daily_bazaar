package services

import (
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/namanjain.3009/daily_bazaar/internal/models"
	"github.com/namanjain.3009/daily_bazaar/internal/repository"
)

type ProductService struct {
	productRepo *repository.ProductRepository
}

func NewProductService(productRepo *repository.ProductRepository) *ProductService {
	return &ProductService{
		productRepo: productRepo,
	}
}

func (s *ProductService) GetAllProducts(params *models.ProductSearchParams) ([]models.Product, error) {
	return s.productRepo.GetAllProducts(params)
}

func (s *ProductService) GetProductByID(id string) (*models.Product, error) {
	if id == "" {
		return nil, errors.New("product ID is required")
	}
	return s.productRepo.GetProductByID(id)
}

func (s *ProductService) GetProductsByCategory(categoryID string) ([]models.Product, error) {
	if categoryID == "" {
		return nil, errors.New("category ID is required")
	}
	return s.productRepo.GetProductsByCategory(categoryID)
}

func (s *ProductService) SearchProducts(query string) ([]models.Product, error) {
	if query == "" {
		return nil, errors.New("search query is required")
	}
	return s.productRepo.SearchProducts(query)
}

func (s *ProductService) CreateProduct(req *models.AddProduct) (*models.Product, error) {
	if req.Name == "" {
		return nil, errors.New("product name is required")
	}
	if req.PriceCents < 0 {
		return nil, errors.New("price cannot be negative")
	}

	product := &models.Product{
		ID:          uuid.New().String(),
		Name:        req.Name,
		Description: req.Description,
		SKU:         req.SKU,
		PriceCents:  req.PriceCents,
		Stock:       req.Stock,
		CategoryID:  req.CategoryID,
		Active:      req.Active,
		CreatedAt:   time.Now(),
		Metadata:    req.Metadata,
	}

	if err := s.productRepo.CreateProduct(product); err != nil {
		return nil, err
	}

	return product, nil
}

func (s *ProductService) UpdateProduct(id string, req *models.UpdateProduct) (*models.Product, error) {
	if id == "" {
		return nil, errors.New("product ID is required")
	}

	// Build updates map with only provided fields
	updates := make(map[string]interface{})

	if req.Name != nil {
		updates["name"] = *req.Name
	}
	if req.Description != nil {
		updates["description"] = *req.Description
	}
	if req.SKU != nil {
		updates["sku"] = *req.SKU
	}
	if req.PriceCents != nil {
		if *req.PriceCents < 0 {
			return nil, errors.New("price cannot be negative")
		}
		updates["price_cents"] = *req.PriceCents
	}
	if req.Stock != nil {
		updates["stock"] = *req.Stock
	}
	if req.CategoryID != nil {
		updates["category_id"] = *req.CategoryID
	}
	if req.Active != nil {
		updates["active"] = *req.Active
	}
	if req.Metadata != nil {
		updates["metadata"] = req.Metadata
	}

	if len(updates) == 0 {
		return nil, errors.New("no fields to update")
	}

	return s.productRepo.UpdateProduct(id, updates)
}

func (s *ProductService) DeleteProduct(id string) error {
	if id == "" {
		return errors.New("product ID is required")
	}
	return s.productRepo.DeleteProduct(id)
}
