package services

import (
	"errors"

	"github.com/google/uuid"
	"github.com/namanjain.3009/daily_bazaar/internal/models"
	"github.com/namanjain.3009/daily_bazaar/internal/repository"
)

type ProductImageService struct {
	imageRepo   *repository.ProductImageRepository
	productRepo *repository.ProductRepository
}

func NewProductImageService(imageRepo *repository.ProductImageRepository, productRepo *repository.ProductRepository) *ProductImageService {
	return &ProductImageService{
		imageRepo:   imageRepo,
		productRepo: productRepo,
	}
}

func (s *ProductImageService) GetImagesByProductID(productID string) ([]models.ProductImage, error) {
	if productID == "" {
		return nil, errors.New("product ID is required")
	}

	// Verify product exists
	_, err := s.productRepo.GetProductByID(productID)
	if err != nil {
		return nil, errors.New("product not found")
	}

	return s.imageRepo.GetImagesByProductID(productID)
}

func (s *ProductImageService) GetImageByID(id string) (*models.ProductImage, error) {
	if id == "" {
		return nil, errors.New("image ID is required")
	}
	return s.imageRepo.GetImageByID(id)
}

func (s *ProductImageService) AddImage(req *models.AddProductImage) (*models.ProductImage, error) {
	if req.ProductID == "" {
		return nil, errors.New("product ID is required")
	}
	if req.URL == "" {
		return nil, errors.New("image URL is required")
	}

	// Verify product exists
	_, err := s.productRepo.GetProductByID(req.ProductID)
	if err != nil {
		return nil, errors.New("product not found")
	}

	// Get max position if not specified
	position := req.Position
	if position == 0 {
		maxPos, err := s.imageRepo.GetMaxPosition(req.ProductID)
		if err == nil {
			position = maxPos + 1
		}
	}

	image := &models.ProductImage{
		ID:        uuid.New().String(),
		ProductID: req.ProductID,
		URL:       req.URL,
		Position:  position,
	}

	if err := s.imageRepo.CreateImage(image); err != nil {
		return nil, err
	}

	return image, nil
}

func (s *ProductImageService) AddMultipleImages(productID string, urls []string) ([]models.ProductImage, error) {
	if productID == "" {
		return nil, errors.New("product ID is required")
	}
	if len(urls) == 0 {
		return nil, errors.New("at least one image URL is required")
	}

	// Verify product exists
	_, err := s.productRepo.GetProductByID(productID)
	if err != nil {
		return nil, errors.New("product not found")
	}

	// Get current max position
	maxPos, _ := s.imageRepo.GetMaxPosition(productID)

	images := make([]models.ProductImage, 0, len(urls))
	for i, url := range urls {
		if url == "" {
			continue
		}
		images = append(images, models.ProductImage{
			ID:        uuid.New().String(),
			ProductID: productID,
			URL:       url,
			Position:  maxPos + i + 1,
		})
	}

	if len(images) == 0 {
		return nil, errors.New("no valid image URLs provided")
	}

	if err := s.imageRepo.CreateImages(images); err != nil {
		return nil, err
	}

	return images, nil
}

func (s *ProductImageService) UpdateImage(id string, req *models.UpdateProductImage) (*models.ProductImage, error) {
	if id == "" {
		return nil, errors.New("image ID is required")
	}

	// Check if image exists
	_, err := s.imageRepo.GetImageByID(id)
	if err != nil {
		return nil, err
	}

	updates := make(map[string]interface{})

	if req.URL != nil {
		if *req.URL == "" {
			return nil, errors.New("image URL cannot be empty")
		}
		updates["url"] = *req.URL
	}
	if req.Position != nil {
		updates["position"] = *req.Position
	}

	if len(updates) == 0 {
		return nil, errors.New("no fields to update")
	}

	return s.imageRepo.UpdateImage(id, updates)
}

func (s *ProductImageService) ReorderImages(productID string, imageIDs []string) error {
	if productID == "" {
		return errors.New("product ID is required")
	}
	if len(imageIDs) == 0 {
		return errors.New("image IDs are required")
	}

	// Update each image's position
	for i, imageID := range imageIDs {
		updates := map[string]interface{}{
			"position": i,
		}
		_, err := s.imageRepo.UpdateImage(imageID, updates)
		if err != nil {
			return err
		}
	}

	return nil
}

func (s *ProductImageService) DeleteImage(id string) error {
	if id == "" {
		return errors.New("image ID is required")
	}
	return s.imageRepo.DeleteImage(id)
}

func (s *ProductImageService) DeleteAllProductImages(productID string) error {
	if productID == "" {
		return errors.New("product ID is required")
	}
	return s.imageRepo.DeleteImagesByProductID(productID)
}

func (s *ProductImageService) SetPrimaryImage(productID, imageID string) error {
	if productID == "" || imageID == "" {
		return errors.New("product ID and image ID are required")
	}

	// Get all images for the product
	images, err := s.imageRepo.GetImagesByProductID(productID)
	if err != nil {
		return err
	}

	// Reorder: put the target image first
	newOrder := []string{imageID}
	for _, img := range images {
		if img.ID != imageID {
			newOrder = append(newOrder, img.ID)
		}
	}

	return s.ReorderImages(productID, newOrder)
}
