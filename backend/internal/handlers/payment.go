package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/namanjain.3009/daily_bazaar/internal/middleware"
	"github.com/namanjain.3009/daily_bazaar/internal/models"
	"github.com/namanjain.3009/daily_bazaar/internal/repository"
	"github.com/namanjain.3009/daily_bazaar/internal/services"
)

type PaymentHandler struct {
	paymentService *services.PaymentService
	userRepo       *repository.UserRepository
}

func NewPaymentHandler(paymentService *services.PaymentService, userRepo *repository.UserRepository) *PaymentHandler {
	return &PaymentHandler{
		paymentService: paymentService,
		userRepo:       userRepo,
	}
}

// InitiatePayment handles POST /api/payments/initiate
func (h *PaymentHandler) InitiatePayment(w http.ResponseWriter, r *http.Request) {
	claims := middleware.GetUserFromContext(r.Context())
	if claims == nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	var req models.InitiatePaymentRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	if req.OrderID == "" || req.CustomerName == "" || req.CustomerEmail == "" {
		http.Error(w, "order_id, customer_name, and customer_email are required", http.StatusBadRequest)
		return
	}

	resp, err := h.paymentService.InitiatePayment(req.OrderID, req.CustomerName, req.CustomerEmail, claims.UserID)
	if err != nil {
		if err.Error() == "access denied" {
			http.Error(w, err.Error(), http.StatusForbidden)
			return
		}
		if err.Error() == "order not found" {
			http.Error(w, err.Error(), http.StatusNotFound)
			return
		}
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

// SubmitReference handles POST /api/payments/reference
func (h *PaymentHandler) SubmitReference(w http.ResponseWriter, r *http.Request) {
	claims := middleware.GetUserFromContext(r.Context())
	if claims == nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	var req models.SubmitReferenceRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	if req.OrderID == "" || req.ReferenceNumber == "" {
		http.Error(w, "order_id and reference_number are required", http.StatusBadRequest)
		return
	}

	err := h.paymentService.SubmitUPIReference(req.OrderID, req.ReferenceNumber, claims.UserID)
	if err != nil {
		if err.Error() == "access denied" {
			http.Error(w, err.Error(), http.StatusForbidden)
			return
		}
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"status":  "success",
		"message": "UPI reference number submitted",
	})
}

// GetPaymentStatus handles GET /api/payments/status/{orderId}
func (h *PaymentHandler) GetPaymentStatus(w http.ResponseWriter, r *http.Request) {
	claims := middleware.GetUserFromContext(r.Context())
	if claims == nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	orderID := r.PathValue("orderId")
	if orderID == "" {
		http.Error(w, "Order ID is required", http.StatusBadRequest)
		return
	}

	isAdmin := h.isUserAdmin(claims.UserID)

	resp, err := h.paymentService.GetPaymentStatus(orderID, claims.UserID, isAdmin)
	if err != nil {
		if err.Error() == "access denied" {
			http.Error(w, err.Error(), http.StatusForbidden)
			return
		}
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

// Webhook handles POST /api/payments/webhook (public - called by UroPay)
func (h *PaymentHandler) Webhook(w http.ResponseWriter, r *http.Request) {
	var payload models.UroPayWebhookPayload
	if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	signature := r.Header.Get("X-Uropay-Signature")
	environment := r.Header.Get("X-Uropay-Environment")

	if err := h.paymentService.HandleWebhook(payload, signature, environment); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
}

func (h *PaymentHandler) isUserAdmin(userID string) bool {
	user, err := h.userRepo.GetUserByID(userID)
	if err != nil {
		return false
	}
	return user.IsAdmin
}
