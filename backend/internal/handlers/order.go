package handlers

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/namanjain.3009/daily_bazaar/internal/middleware"
	"github.com/namanjain.3009/daily_bazaar/internal/models"
	"github.com/namanjain.3009/daily_bazaar/internal/repository"
	"github.com/namanjain.3009/daily_bazaar/internal/services"
)

type OrderHandler struct {
	orderService *services.OrderService
	userRepo     *repository.UserRepository
}

func NewOrderHandler(orderService *services.OrderService, userRepo *repository.UserRepository) *OrderHandler {
	return &OrderHandler{
		orderService: orderService,
		userRepo:     userRepo,
	}
}

// CreateOrder handles POST /api/orders
func (h *OrderHandler) CreateOrder(w http.ResponseWriter, r *http.Request) {
	claims := middleware.GetUserFromContext(r.Context())
	if claims == nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	var req models.CreateOrderRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	order, err := h.orderService.CreateOrder(claims.UserID, &req)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(order)
}

// GetMyOrders handles GET /api/orders/my
func (h *OrderHandler) GetMyOrders(w http.ResponseWriter, r *http.Request) {
	claims := middleware.GetUserFromContext(r.Context())
	if claims == nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	orders, err := h.orderService.GetUserOrders(claims.UserID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(orders)
}

// GetOrderByID handles GET /api/orders/{id}
func (h *OrderHandler) GetOrderByID(w http.ResponseWriter, r *http.Request) {
	claims := middleware.GetUserFromContext(r.Context())
	if claims == nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	id := r.PathValue("id")
	if id == "" {
		http.Error(w, "Order ID is required", http.StatusBadRequest)
		return
	}

	// Check if user is admin
	isAdmin := h.isUserAdmin(claims.UserID)

	order, err := h.orderService.GetOrderByID(id, claims.UserID, isAdmin)
	if err != nil {
		if err.Error() == "order not found" {
			http.Error(w, err.Error(), http.StatusNotFound)
			return
		}
		if err.Error() == "access denied" {
			http.Error(w, err.Error(), http.StatusForbidden)
			return
		}
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(order)
}

// GetAllOrders handles GET /api/orders (Admin only)
func (h *OrderHandler) GetAllOrders(w http.ResponseWriter, r *http.Request) {
	status := r.URL.Query().Get("status")
	limit := 0
	offset := 0

	if l := r.URL.Query().Get("limit"); l != "" {
		if parsed, err := strconv.Atoi(l); err == nil {
			limit = parsed
		}
	}
	if o := r.URL.Query().Get("offset"); o != "" {
		if parsed, err := strconv.Atoi(o); err == nil {
			offset = parsed
		}
	}

	orders, err := h.orderService.GetAllOrders(status, limit, offset)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(orders)
}

// UpdateOrderStatus handles PUT /api/orders/{id}/status (Admin only)
func (h *OrderHandler) UpdateOrderStatus(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	if id == "" {
		http.Error(w, "Order ID is required", http.StatusBadRequest)
		return
	}

	var req models.UpdateOrderStatus
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	order, err := h.orderService.UpdateOrderStatus(id, req.Status)
	if err != nil {
		if err.Error() == "order not found" {
			http.Error(w, err.Error(), http.StatusNotFound)
			return
		}
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(order)
}

// CancelOrder handles POST /api/orders/{id}/cancel
func (h *OrderHandler) CancelOrder(w http.ResponseWriter, r *http.Request) {
	claims := middleware.GetUserFromContext(r.Context())
	if claims == nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	id := r.PathValue("id")
	if id == "" {
		http.Error(w, "Order ID is required", http.StatusBadRequest)
		return
	}

	isAdmin := h.isUserAdmin(claims.UserID)

	order, err := h.orderService.CancelOrder(id, claims.UserID, isAdmin)
	if err != nil {
		if err.Error() == "order not found" {
			http.Error(w, err.Error(), http.StatusNotFound)
			return
		}
		if err.Error() == "access denied" {
			http.Error(w, err.Error(), http.StatusForbidden)
			return
		}
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(order)
}

func (h *OrderHandler) isUserAdmin(userID string) bool {
	user, err := h.userRepo.GetUserByID(userID)
	if err != nil {
		return false
	}
	return user.IsAdmin
}
