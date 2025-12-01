package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/namanjain.3009/daily_bazaar/internal/middleware"
	"github.com/namanjain.3009/daily_bazaar/internal/models"
	"github.com/namanjain.3009/daily_bazaar/internal/services"
)

type ProductImageHandler struct {
	imageService *services.ProductImageService
}

func NewProductImageHandler(imageService *services.ProductImageService) *ProductImageHandler {
	return &ProductImageHandler{imageService: imageService}
}

// GetProductImages handles GET /api/products/{productId}/images
func (h *ProductImageHandler) GetProductImages(w http.ResponseWriter, r *http.Request) {
	productID := r.PathValue("productId")
	if productID == "" {
		http.Error(w, "Product ID is required", http.StatusBadRequest)
		return
	}

	images, err := h.imageService.GetImagesByProductID(productID)
	if err != nil {
		if err.Error() == "product not found" {
			http.Error(w, err.Error(), http.StatusNotFound)
			return
		}
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(images)
}

// GetImageByID handles GET /api/product-images/{id}
func (h *ProductImageHandler) GetImageByID(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	if id == "" {
		http.Error(w, "Image ID is required", http.StatusBadRequest)
		return
	}

	image, err := h.imageService.GetImageByID(id)
	if err != nil {
		if err.Error() == "image not found" {
			http.Error(w, err.Error(), http.StatusNotFound)
			return
		}
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(image)
}

// AddImage handles POST /api/products/{productId}/images (Admin only)
func (h *ProductImageHandler) AddImage(w http.ResponseWriter, r *http.Request) {
	claims := middleware.GetUserFromContext(r.Context())
	if claims == nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	productID := r.PathValue("productId")
	if productID == "" {
		http.Error(w, "Product ID is required", http.StatusBadRequest)
		return
	}

	var req models.AddProductImage
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	req.ProductID = productID

	image, err := h.imageService.AddImage(&req)
	if err != nil {
		if err.Error() == "product not found" {
			http.Error(w, err.Error(), http.StatusNotFound)
			return
		}
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(image)
}

// AddMultipleImages handles POST /api/products/{productId}/images/bulk (Admin only)
func (h *ProductImageHandler) AddMultipleImages(w http.ResponseWriter, r *http.Request) {
	claims := middleware.GetUserFromContext(r.Context())
	if claims == nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	productID := r.PathValue("productId")
	if productID == "" {
		http.Error(w, "Product ID is required", http.StatusBadRequest)
		return
	}

	var req struct {
		URLs []string `json:"urls"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	images, err := h.imageService.AddMultipleImages(productID, req.URLs)
	if err != nil {
		if err.Error() == "product not found" {
			http.Error(w, err.Error(), http.StatusNotFound)
			return
		}
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(images)
}

// UpdateImage handles PUT /api/product-images/{id} (Admin only)
func (h *ProductImageHandler) UpdateImage(w http.ResponseWriter, r *http.Request) {
	claims := middleware.GetUserFromContext(r.Context())
	if claims == nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	id := r.PathValue("id")
	if id == "" {
		http.Error(w, "Image ID is required", http.StatusBadRequest)
		return
	}

	var req models.UpdateProductImage
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	image, err := h.imageService.UpdateImage(id, &req)
	if err != nil {
		if err.Error() == "image not found" {
			http.Error(w, err.Error(), http.StatusNotFound)
			return
		}
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(image)
}

// ReorderImages handles PUT /api/products/{productId}/images/reorder (Admin only)
func (h *ProductImageHandler) ReorderImages(w http.ResponseWriter, r *http.Request) {
	claims := middleware.GetUserFromContext(r.Context())
	if claims == nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	productID := r.PathValue("productId")
	if productID == "" {
		http.Error(w, "Product ID is required", http.StatusBadRequest)
		return
	}

	var req models.ReorderProductImages
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	if err := h.imageService.ReorderImages(productID, req.ImageIDs); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "Images reordered successfully"})
}

// SetPrimaryImage handles PUT /api/products/{productId}/images/{imageId}/primary (Admin only)
func (h *ProductImageHandler) SetPrimaryImage(w http.ResponseWriter, r *http.Request) {
	claims := middleware.GetUserFromContext(r.Context())
	if claims == nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	productID := r.PathValue("productId")
	imageID := r.PathValue("imageId")
	if productID == "" || imageID == "" {
		http.Error(w, "Product ID and Image ID are required", http.StatusBadRequest)
		return
	}

	if err := h.imageService.SetPrimaryImage(productID, imageID); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "Primary image set successfully"})
}

// DeleteImage handles DELETE /api/product-images/{id} (Admin only)
func (h *ProductImageHandler) DeleteImage(w http.ResponseWriter, r *http.Request) {
	claims := middleware.GetUserFromContext(r.Context())
	if claims == nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	id := r.PathValue("id")
	if id == "" {
		http.Error(w, "Image ID is required", http.StatusBadRequest)
		return
	}

	if err := h.imageService.DeleteImage(id); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

// DeleteAllProductImages handles DELETE /api/products/{productId}/images (Admin only)
func (h *ProductImageHandler) DeleteAllProductImages(w http.ResponseWriter, r *http.Request) {
	claims := middleware.GetUserFromContext(r.Context())
	if claims == nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	productID := r.PathValue("productId")
	if productID == "" {
		http.Error(w, "Product ID is required", http.StatusBadRequest)
		return
	}

	if err := h.imageService.DeleteAllProductImages(productID); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}
