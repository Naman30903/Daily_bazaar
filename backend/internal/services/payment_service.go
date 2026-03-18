package services

import (
	"bytes"
	"crypto/hmac"
	"crypto/sha256"
	"crypto/sha512"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"net/http"
	"sort"
	"strings"

	"github.com/namanjain.3009/daily_bazaar/internal/config"
	"github.com/namanjain.3009/daily_bazaar/internal/models"
	"github.com/namanjain.3009/daily_bazaar/internal/repository"
)

const uroPayBaseURL = "https://api.uropay.me"

type PaymentService struct {
	cfg       *config.Config
	orderRepo *repository.OrderRepository
	hashedSecret string
}

func NewPaymentService(cfg *config.Config, orderRepo *repository.OrderRepository) *PaymentService {
	// Pre-compute SHA-512 hash of the secret
	h := sha512.New()
	h.Write([]byte(cfg.UroPaySecret))
	hashed := hex.EncodeToString(h.Sum(nil))

	return &PaymentService{
		cfg:          cfg,
		orderRepo:    orderRepo,
		hashedSecret: hashed,
	}
}

// InitiatePayment creates a UroPay order for an existing Daily Bazaar order.
func (s *PaymentService) InitiatePayment(orderID, customerName, customerEmail string, userID string, amountFromFrontend float64) (*models.InitiatePaymentResponse, error) {
	order, err := s.orderRepo.GetOrderByID(orderID)
	if err != nil {
		return nil, errors.New("order not found")
	}
	if order.UserID != userID {
		return nil, errors.New("access denied")
	}
	if order.Status != models.OrderStatusPending {
		return nil, errors.New("order is not in pending status")
	}

	// Check if payment already initiated
	if pm := order.PaymentMetadata; pm != nil {
		if uroID, ok := pm["uropay_order_id"].(string); ok && uroID != "" {
			// Already initiated — return existing data
			return &models.InitiatePaymentResponse{
				UroPayOrderId:  uroID,
				UPIString:      stringFromMap(pm, "upi_string"),
				QRCode:         stringFromMap(pm, "qr_code"),
				AmountInRupees: stringFromMap(pm, "amount_in_rupees"),
				PaymentStatus:  stringFromMap(pm, "payment_status"),
			}, nil
		}
	}

	// Use the amount from frontend (in rupees) since DB price units may differ
	amountRupees := amountFromFrontend
	if amountRupees <= 0 {
		// Fallback to order total
		amountRupees = float64(order.TotalCents) / 100.0
	}

	// UroPay requires a non-empty customerEmail
	if customerEmail == "" {
		customerEmail = "customer@dailybazaar.com"
	}

	reqBody := models.UroPayGenerateRequest{
		VPA:             s.cfg.UroPayVPA,
		VPAName:         s.cfg.UroPayVPAName,
		Amount:          amountRupees,
		MerchantOrderId: orderID,
		CustomerName:    customerName,
		CustomerEmail:   customerEmail,
		TransactionNote: fmt.Sprintf("Order %s", orderID[:8]),
		Notes: map[string]string{
			"order_id": orderID,
		},
	}

	bodyBytes, _ := json.Marshal(reqBody)
	req, err := http.NewRequest("POST", uroPayBaseURL+"/order/generate", bytes.NewReader(bodyBytes))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
	req.Header.Set("X-API-KEY", s.cfg.UroPayAPIKey)
	req.Header.Set("Authorization", "Bearer "+s.hashedSecret)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("UroPay API error: %w", err)
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)
	log.Printf("UroPay /order/generate response [%d]: %s", resp.StatusCode, string(respBody))

	var uroResp models.UroPayGenerateResponse
	if err := json.Unmarshal(respBody, &uroResp); err != nil {
		return nil, fmt.Errorf("UroPay API returned %d: %s", resp.StatusCode, string(respBody))
	}

	if uroResp.Code != 200 {
		return nil, fmt.Errorf("UroPay error (%d): %s", uroResp.Code, string(uroResp.Message))
	}

	// Store payment metadata in order
	paymentMeta := map[string]interface{}{
		"gateway":          "uropay",
		"uropay_order_id":  uroResp.Data.UroPayOrderId,
		"upi_string":       uroResp.Data.UPIString,
		"qr_code":          uroResp.Data.QRCode,
		"amount_in_rupees": uroResp.Data.AmountInRupees.String(),
		"payment_status":   models.PaymentStatusCreated,
	}

	if err := s.orderRepo.UpdatePaymentMetadata(orderID, paymentMeta); err != nil {
		log.Printf("Failed to update payment metadata for order %s: %v", orderID, err)
	}

	return &models.InitiatePaymentResponse{
		UroPayOrderId:  uroResp.Data.UroPayOrderId,
		UPIString:      uroResp.Data.UPIString,
		QRCode:         uroResp.Data.QRCode,
		AmountInRupees: uroResp.Data.AmountInRupees.String(),
		PaymentStatus:  models.PaymentStatusCreated,
	}, nil
}

// SubmitUPIReference updates the UroPay order with the customer's UPI reference number.
func (s *PaymentService) SubmitUPIReference(orderID, referenceNumber, userID string) error {
	order, err := s.orderRepo.GetOrderByID(orderID)
	if err != nil {
		return errors.New("order not found")
	}
	if order.UserID != userID {
		return errors.New("access denied")
	}

	uroPayOrderId := stringFromMap(order.PaymentMetadata, "uropay_order_id")
	if uroPayOrderId == "" {
		return errors.New("payment not initiated for this order")
	}

	reqBody := models.UroPayUpdateRequest{
		UroPayOrderId:   uroPayOrderId,
		ReferenceNumber: referenceNumber,
	}

	bodyBytes, _ := json.Marshal(reqBody)
	req, err := http.NewRequest("PATCH", uroPayBaseURL+"/order/update", bytes.NewReader(bodyBytes))
	if err != nil {
		return fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
	req.Header.Set("X-API-KEY", s.cfg.UroPayAPIKey)
	req.Header.Set("Authorization", "Bearer "+s.hashedSecret)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return fmt.Errorf("UroPay API error: %w", err)
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)

	var uroResp models.UroPayUpdateResponse
	if err := json.Unmarshal(respBody, &uroResp); err != nil {
		return fmt.Errorf("failed to parse UroPay response: %w", err)
	}

	if uroResp.Code != 200 {
		return fmt.Errorf("UroPay error: %s", uroResp.Message)
	}

	// Update payment metadata
	pm := order.PaymentMetadata
	if pm == nil {
		pm = map[string]interface{}{}
	}
	pm["reference_number"] = referenceNumber
	pm["payment_status"] = models.PaymentStatusUpdated

	return s.orderRepo.UpdatePaymentMetadata(orderID, pm)
}

// GetPaymentStatus checks the payment status from UroPay and locally.
func (s *PaymentService) GetPaymentStatus(orderID, userID string, isAdmin bool) (*models.PaymentStatusResponse, error) {
	order, err := s.orderRepo.GetOrderByID(orderID)
	if err != nil {
		return nil, errors.New("order not found")
	}
	if !isAdmin && order.UserID != userID {
		return nil, errors.New("access denied")
	}

	uroPayOrderId := stringFromMap(order.PaymentMetadata, "uropay_order_id")
	paymentStatus := stringFromMap(order.PaymentMetadata, "payment_status")

	result := &models.PaymentStatusResponse{
		OrderID:       orderID,
		PaymentStatus: paymentStatus,
		UroPayOrderId: uroPayOrderId,
	}

	// If we have a UroPay order ID, poll their status endpoint
	if uroPayOrderId != "" && paymentStatus != models.PaymentStatusCompleted {
		req, err := http.NewRequest("GET", uroPayBaseURL+"/order/status/"+uroPayOrderId, nil)
		if err == nil {
			req.Header.Set("Accept", "application/json")
			req.Header.Set("Content-Type", "application/json")
			req.Header.Set("X-API-KEY", s.cfg.UroPayAPIKey)

			resp, err := http.DefaultClient.Do(req)
			if err == nil {
				defer resp.Body.Close()
				respBody, _ := io.ReadAll(resp.Body)
				var statusResp models.UroPayStatusResponse
				if json.Unmarshal(respBody, &statusResp) == nil && statusResp.Code == 200 {
					result.UroPayStatus = statusResp.Data.OrderStatus

					// If UroPay says COMPLETED, update our order
					if strings.EqualFold(statusResp.Data.OrderStatus, "COMPLETED") {
						s.markPaymentCompleted(orderID, order.PaymentMetadata)
						result.PaymentStatus = models.PaymentStatusCompleted
					}
				}
			}
		}
	}

	return result, nil
}

// HandleWebhook processes a UroPay webhook callback.
func (s *PaymentService) HandleWebhook(payload models.UroPayWebhookPayload, signature, environment string) error {
	// Verify webhook signature
	if !s.verifyWebhookSignature(payload, signature, environment) {
		return errors.New("invalid webhook signature")
	}

	if payload.ReferenceNumber == "" {
		return errors.New("missing reference number")
	}

	// Find the order by reference number in payment metadata
	// We need to search orders that have this reference number
	orders, err := s.orderRepo.GetAllOrders("", 0, 0)
	if err != nil {
		return fmt.Errorf("failed to search orders: %w", err)
	}

	for _, order := range orders {
		refNum := stringFromMap(order.PaymentMetadata, "reference_number")
		uroID := stringFromMap(order.PaymentMetadata, "uropay_order_id")
		if refNum == payload.ReferenceNumber || uroID != "" {
			// Verify amount matches (payload amount is in rupees as string)
			s.markPaymentCompleted(order.ID, order.PaymentMetadata)
			log.Printf("Webhook: payment completed for order %s, ref %s", order.ID, payload.ReferenceNumber)
			return nil
		}
	}

	log.Printf("Webhook: no matching order found for reference %s", payload.ReferenceNumber)
	return nil
}

func (s *PaymentService) markPaymentCompleted(orderID string, pm map[string]interface{}) {
	if pm == nil {
		pm = map[string]interface{}{}
	}
	pm["payment_status"] = models.PaymentStatusCompleted

	if err := s.orderRepo.UpdatePaymentMetadata(orderID, pm); err != nil {
		log.Printf("Failed to update payment metadata for order %s: %v", orderID, err)
		return
	}

	// Move order to confirmed status
	if _, err := s.orderRepo.UpdateOrderStatus(orderID, models.OrderStatusConfirmed); err != nil {
		log.Printf("Failed to confirm order %s after payment: %v", orderID, err)
	}
}

func (s *PaymentService) verifyWebhookSignature(payload models.UroPayWebhookPayload, signature, environment string) bool {
	if s.hashedSecret == "" || signature == "" {
		return false
	}

	// Build sorted data + environment
	data := map[string]string{
		"amount":          payload.Amount,
		"from":            payload.From,
		"referenceNumber": payload.ReferenceNumber,
		"vpa":             payload.VPA,
	}

	keys := make([]string, 0, len(data))
	for k := range data {
		keys = append(keys, k)
	}
	sort.Strings(keys)

	sorted := make(map[string]string)
	for _, k := range keys {
		sorted[k] = data[k]
	}
	sorted["environment"] = environment

	payloadBytes, _ := json.Marshal(sorted)

	mac := hmac.New(sha256.New, []byte(s.hashedSecret))
	mac.Write(payloadBytes)
	expected := hex.EncodeToString(mac.Sum(nil))

	return hmac.Equal([]byte(expected), []byte(signature))
}

func stringFromMap(m map[string]interface{}, key string) string {
	if m == nil {
		return ""
	}
	v, ok := m[key]
	if !ok {
		return ""
	}
	s, ok := v.(string)
	if !ok {
		return ""
	}
	return s
}
