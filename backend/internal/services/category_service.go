package services

import (
	"errors"
	"net/url"
	"regexp"
	"strings"

	"github.com/google/uuid"
	"github.com/namanjain.3009/daily_bazaar/internal/models"
	"github.com/namanjain.3009/daily_bazaar/internal/repository"
)

type CategoryService struct {
	categoryRepo *repository.CategoryRepository
}

func NewCategoryService(categoryRepo *repository.CategoryRepository) *CategoryService {
	return &CategoryService{
		categoryRepo: categoryRepo,
	}
}

func (s *CategoryService) GetAllCategories() ([]models.Category, error) {
	return s.categoryRepo.GetAllCategories()
}

func (s *CategoryService) GetCategoryByID(id string) (*models.Category, error) {
	if id == "" {
		return nil, errors.New("category ID is required")
	}
	return s.categoryRepo.GetCategoryByID(id)
}

func (s *CategoryService) GetCategoryBySlug(slug string) (*models.Category, error) {
	if slug == "" {
		return nil, errors.New("category slug is required")
	}
	return s.categoryRepo.GetCategoryBySlug(slug)
}

func (s *CategoryService) GetSubcategories(parentID string) ([]models.Category, error) {
	if parentID == "" {
		return nil, errors.New("parent ID is required")
	}
	return s.categoryRepo.GetSubcategories(parentID)
}

func (s *CategoryService) GetRootCategories(minPosition, maxPosition *int) ([]models.Category, error) {
	// Basic validation if both provided
	if minPosition != nil && maxPosition != nil && *minPosition > *maxPosition {
		return nil, errors.New("min_position cannot be greater than max_position")
	}
	return s.categoryRepo.GetRootCategories(minPosition, maxPosition)
}

func (s *CategoryService) CreateCategory(req *models.AddCategory) (*models.Category, error) {
	if req.Name == "" {
		return nil, errors.New("category name is required")
	}
	if req.Slug == "" {
		return nil, errors.New("category slug is required")
	}

	// Validate slug format (lowercase, alphanumeric, hyphens only)
	if !isValidSlug(req.Slug) {
		return nil, errors.New("invalid slug format: use lowercase letters, numbers, and hyphens only")
	}

	// Check if slug already exists
	existing, _ := s.categoryRepo.GetCategoryBySlug(req.Slug)
	if existing != nil {
		return nil, errors.New("category with this slug already exists")
	}

	// Validate parent_id if provided
	if req.ParentID != "" {
		_, err := s.categoryRepo.GetCategoryByID(req.ParentID)
		if err != nil {
			return nil, errors.New("parent category not found")
		}
	}

	// NEW: Validate image URL if provided
	if req.ImageURL != "" {
		if !isValidURL(req.ImageURL) {
			return nil, errors.New("invalid image URL format")
		}
	}

	category := &models.Category{
		ID:       uuid.New().String(),
		Name:     req.Name,
		Slug:     req.Slug,
		ParentID: req.ParentID,
		Position: req.Position,
		ImageURL: req.ImageURL, // NEW
	}

	if err := s.categoryRepo.CreateCategory(category); err != nil {
		return nil, err
	}

	return category, nil
}

func (s *CategoryService) UpdateCategory(id string, req *models.UpdateCategory) (*models.Category, error) {
	if id == "" {
		return nil, errors.New("category ID is required")
	}

	// Build updates map with only provided fields
	updates := make(map[string]interface{})

	if req.Name != nil {
		if *req.Name == "" {
			return nil, errors.New("category name cannot be empty")
		}
		updates["name"] = *req.Name
	}

	if req.Slug != nil {
		if *req.Slug == "" {
			return nil, errors.New("category slug cannot be empty")
		}
		if !isValidSlug(*req.Slug) {
			return nil, errors.New("invalid slug format: use lowercase letters, numbers, and hyphens only")
		}
		// Check if slug already exists for a different category
		existing, _ := s.categoryRepo.GetCategoryBySlug(*req.Slug)
		if existing != nil && existing.ID != id {
			return nil, errors.New("category with this slug already exists")
		}
		updates["slug"] = *req.Slug
	}

	if req.ParentID != nil {
		if *req.ParentID != "" {
			// Prevent setting itself as parent
			if *req.ParentID == id {
				return nil, errors.New("category cannot be its own parent")
			}
			// Validate parent exists
			_, err := s.categoryRepo.GetCategoryByID(*req.ParentID)
			if err != nil {
				return nil, errors.New("parent category not found")
			}
		}
		updates["parent_id"] = *req.ParentID
	}

	if req.Position != nil {
		updates["position"] = *req.Position
	}

	// NEW: Handle image URL update
	if req.ImageURL != nil {
		if *req.ImageURL != "" && !isValidURL(*req.ImageURL) {
			return nil, errors.New("invalid image URL format")
		}
		updates["image_url"] = *req.ImageURL
	}

	if len(updates) == 0 {
		return nil, errors.New("no fields to update")
	}

	return s.categoryRepo.UpdateCategory(id, updates)
}

func (s *CategoryService) DeleteCategory(id string) error {
	if id == "" {
		return errors.New("category ID is required")
	}

	// Check if category has subcategories
	subcategories, err := s.categoryRepo.GetSubcategories(id)
	if err == nil && len(subcategories) > 0 {
		return errors.New("cannot delete category with subcategories")
	}

	return s.categoryRepo.DeleteCategory(id)
}

// isValidSlug checks if the slug is valid (lowercase, alphanumeric, hyphens)
func isValidSlug(slug string) bool {
	if slug != strings.ToLower(slug) {
		return false
	}
	matched, _ := regexp.MatchString(`^[a-z0-9]+(-[a-z0-9]+)*$`, slug)
	return matched
}

// NEW: isValidURL validates URL format
func isValidURL(urlStr string) bool {
	if urlStr == "" {
		return true // empty is valid (nullable)
	}
	parsedURL, err := url.ParseRequestURI(urlStr)
	if err != nil {
		return false
	}
	// Check if scheme is http or https
	return parsedURL.Scheme == "http" || parsedURL.Scheme == "https"
}
