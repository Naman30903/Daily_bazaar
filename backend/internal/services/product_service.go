package services

import (
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/namanjain.3009/daily_bazaar/internal/models"
	"github.com/namanjain.3009/daily_bazaar/internal/repository"
	"github.com/namanjain.3009/daily_bazaar/internal/utils"
)

type ProductService struct {
	productRepo  *repository.ProductRepository
	categoryRepo *repository.CategoryRepository
}

func NewProductService(productRepo *repository.ProductRepository, categoryRepo *repository.CategoryRepository) *ProductService {
	return &ProductService{
		productRepo:  productRepo,
		categoryRepo: categoryRepo,
	}
}

// CreateProduct: transactional create with categories
func (s *ProductService) CreateProduct(req *models.AddProduct) (*models.Product, error) {
	// Validation
	if req.Name == "" {
		return nil, errors.New("product name is required")
	}
	if req.PriceCents < 0 {
		return nil, errors.New("price cannot be negative")
	}
	if len(req.CategoryIDs) == 0 {
		return nil, errors.New("at least one category is required")
	}

	// Validate all categories exist
	if err := s.validateCategories(req.CategoryIDs); err != nil {
		return nil, err
	}

	// Create product
	product := &models.Product{
		ID:          uuid.New().String(),
		Name:        req.Name,
		Description: req.Description,
		SKU:         req.SKU,
		PriceCents:  req.PriceCents,
		Stock:       req.Stock,
		Active:      req.Active,
		CreatedAt:   time.Now(),
		Metadata:    req.Metadata,
		MRPCents:    req.MRPCents,
		Weight:      req.Weight,
	}

	// Step 1: Insert product
	if err := s.productRepo.CreateProduct(product); err != nil {
		return nil, err
	}

	// Step 2: Link categories (if this fails, manual rollback needed)
	if err := s.productRepo.LinkProductCategories(product.ID, req.CategoryIDs); err != nil {
		// Attempt rollback
		s.productRepo.DeleteProduct(product.ID)
		return nil, errors.New("failed to link categories: " + err.Error())
	}

	// Step 3: Insert Variants
	if len(req.Variants) > 0 {
		if err := s.productRepo.ReplaceProductVariants(product.ID, req.Variants); err != nil {
			return nil, errors.New("failed to add variants: " + err.Error())
		}
	}

	// Step 4: Insert Images
	if len(req.Images) > 0 {
		if err := s.productRepo.ReplaceProductImages(product.ID, req.Images); err != nil {
			return nil, errors.New("failed to add images: " + err.Error())
		}
	}

	// Step 5: Fetch full product with categories, variants, images
	return s.productRepo.GetProductByID(product.ID)
}

// UpdateProduct: transactional update with optional category replacement
func (s *ProductService) UpdateProduct(id string, req *models.UpdateProduct) (*models.Product, error) {
	if id == "" {
		return nil, errors.New("product ID is required")
	}

	// Check if product exists
	_, err := s.productRepo.GetProductByID(id)
	if err != nil {
		return nil, err
	}

	// Build product field updates
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
	if req.Active != nil {
		updates["active"] = *req.Active
	}
	if req.Metadata != nil {
		updates["metadata"] = req.Metadata
	}
	if req.MRPCents != nil {
		updates["mrp_cents"] = *req.MRPCents
	}
	if req.Weight != nil {
		updates["weight"] = *req.Weight
	}

	// Update product fields if any
	if len(updates) > 0 {
		if _, err := s.productRepo.UpdateProduct(id, updates); err != nil {
			return nil, err
		}
	}

	// Handle category replacement if provided
	if len(req.CategoryIDs) > 0 {
		// Validate categories
		if err := s.validateCategories(req.CategoryIDs); err != nil {
			return nil, err
		}

		// Step 1: Delete old mappings
		if err := s.productRepo.UnlinkAllProductCategories(id); err != nil {
			return nil, errors.New("failed to unlink old categories: " + err.Error())
		}

		// Step 2: Insert new mappings
		if err := s.productRepo.LinkProductCategories(id, req.CategoryIDs); err != nil {
			return nil, errors.New("failed to link new categories: " + err.Error())
		}
	}

	// Handle variants replacement if provided (nil means no update, empty slice means clear all)
	if req.Variants != nil {
		if err := s.productRepo.ReplaceProductVariants(id, req.Variants); err != nil {
			return nil, err
		}
	}

	// Handle images replacement if provided
	if req.Images != nil {
		// Set ProductID involved in images just in case, though repo handles it
		if err := s.productRepo.ReplaceProductImages(id, req.Images); err != nil {
			return nil, err
		}
	}

	// Return updated product with categories
	return s.productRepo.GetProductByID(id)
}

// GetAllProducts with optional category filter
func (s *ProductService) GetAllProducts(params *models.ProductSearchParams) ([]models.Product, error) {
	return s.productRepo.GetAllProducts(params)
}

// GetProductsByCategorySQL uses raw SQL via RPC to get products by category
func (s *ProductService) GetProductsByCategorySQL(categoryID string, limit, offset int) ([]models.Product, error) {
	if categoryID == "" {
		return nil, errors.New("category ID is required")
	}
	if limit <= 0 {
		limit = 10 // default limit
	}
	return s.productRepo.GetProductsByCategorySQL(categoryID, limit, offset)
}

func (s *ProductService) GetProductByID(id string) (*models.Product, error) {
	if id == "" {
		return nil, errors.New("product ID is required")
	}
	return s.productRepo.GetProductByID(id)
}

func (s *ProductService) SearchProducts(query string) ([]models.Product, error) {
	return s.SearchProductsWithPagination(query, 50, 0)
}

// SearchProductsWithPagination searches products with optional limit and offset.
func (s *ProductService) SearchProductsWithPagination(query string, limit, offset int) ([]models.Product, error) {
	if query == "" {
		return nil, errors.New("search query is required")
	}
	if limit <= 0 {
		limit = 50
	}
	return s.productRepo.SearchProductsWithLimit(query, limit, offset)
}

// GetSearchSuggestions returns fuzzy-matched product name suggestions for autocomplete.
func (s *ProductService) GetSearchSuggestions(query string, limit int) ([]string, error) {
	if query == "" {
		return nil, errors.New("search query is required")
	}
	if limit <= 0 {
		limit = 10
	}

	// Get all product names for fuzzy matching
	names, err := s.productRepo.GetAllProductNames()
	if err != nil {
		return nil, err
	}

	// Use fuzzy search to find matching names
	suggestions := utils.FuzzySearchProducts(query, names, limit)
	return suggestions, nil
}

// GetAllProductNames returns all active product names for indexing.
func (s *ProductService) GetAllProductNames() ([]string, error) {
	return s.productRepo.GetAllProductNames()
}

func (s *ProductService) DeleteProduct(id string) error {
	if id == "" {
		return errors.New("product ID is required")
	}
	// Cascade will auto-delete product_categories
	return s.productRepo.DeleteProduct(id)
}

// validateCategories checks if all category IDs exist
func (s *ProductService) validateCategories(categoryIDs []string) error {
	if len(categoryIDs) == 0 {
		return errors.New("category IDs cannot be empty")
	}

	for _, catID := range categoryIDs {
		if _, err := uuid.Parse(catID); err != nil {
			return errors.New("invalid category UUID: " + catID)
		}

		// Check if category exists
		if _, err := s.categoryRepo.GetCategoryByID(catID); err != nil {
			return errors.New("category not found: " + catID)
		}
	}

	return nil
}
