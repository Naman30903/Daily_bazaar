package models

import "time"

type Order struct {
	ID              string                 `json:"id"`
	UserID          string                 `json:"user_id,omitempty"`
	SubtotalCents   int64                  `json:"subtotal_cents"`
	ShippingCents   int64                  `json:"shipping_cents"`
	TaxCents        int64                  `json:"tax_cents"`
	TotalCents      int64                  `json:"total_cents"`
	Status          string                 `json:"status"`
	PlacedAt        time.Time              `json:"placed_at"`
	ShippingAddress map[string]interface{} `json:"shipping_address,omitempty"`
	PaymentMetadata map[string]interface{} `json:"payment_metadata,omitempty"`
	Items           []OrderItem            `json:"items,omitempty"`
}

type OrderItem struct {
	ID             string `json:"id"`
	OrderID        string `json:"order_id"`
	ProductID      string `json:"product_id"`
	Quantity       int    `json:"quantity"`
	UnitPriceCents int64  `json:"unit_price_cents"`
}

type CreateOrderRequest struct {
	ShippingAddress map[string]interface{} `json:"shipping_address"`
	PaymentMetadata map[string]interface{} `json:"payment_metadata,omitempty"`
	Items           []CreateOrderItem      `json:"items"`
}

type CreateOrderItem struct {
	ProductID string `json:"product_id"`
	Quantity  int    `json:"quantity"`
}

type UpdateOrderStatus struct {
	Status string `json:"status"`
}

// Order statuses
const (
	OrderStatusPending    = "pending"
	OrderStatusConfirmed  = "confirmed"
	OrderStatusProcessing = "processing"
	OrderStatusShipped    = "shipped"
	OrderStatusDelivered  = "delivered"
	OrderStatusCancelled  = "cancelled"
)

// Payment statuses
const (
	PaymentStatusPending   = "payment_pending"
	PaymentStatusCreated   = "payment_created"   // UroPay order generated
	PaymentStatusUpdated   = "payment_updated"   // UPI ref submitted
	PaymentStatusCompleted = "payment_completed"  // Payment confirmed
	PaymentStatusFailed    = "payment_failed"
)

// UroPay API types

type UroPayGenerateRequest struct {
	VPA             string            `json:"vpa"`
	VPAName         string            `json:"vpaName"`
	Amount          int64             `json:"amount"` // in paise
	MerchantOrderId string            `json:"merchantOrderId"`
	CustomerName    string            `json:"customerName"`
	CustomerEmail   string            `json:"customerEmail"`
	TransactionNote string            `json:"transactionNote,omitempty"`
	Notes           map[string]string `json:"notes,omitempty"`
}

type UroPayGenerateResponse struct {
	Code    int    `json:"code"`
	Status  string `json:"status"`
	Message string `json:"message"`
	Data    struct {
		UroPayOrderId  string `json:"uroPayOrderId"`
		OrderStatus    string `json:"orderStatus"`
		UPIString      string `json:"upiString"`
		QRCode         string `json:"qrCode"`
		AmountInRupees string `json:"amountInRupees"`
	} `json:"data"`
}

type UroPayUpdateRequest struct {
	UroPayOrderId   string `json:"uroPayOrderId"`
	ReferenceNumber string `json:"referenceNumber"`
}

type UroPayUpdateResponse struct {
	Code    int    `json:"code"`
	Status  string `json:"status"`
	Message string `json:"message"`
	Data    struct {
		UroPayOrderId string `json:"uroPayOrderId"`
		OrderStatus   string `json:"orderStatus"`
	} `json:"data"`
}

type UroPayStatusResponse struct {
	Code    int    `json:"code"`
	Status  string `json:"status"`
	Message string `json:"message"`
	Data    struct {
		UroPayOrderId string `json:"uroPayOrderId"`
		OrderStatus   string `json:"orderStatus"`
	} `json:"data"`
}

type UroPayWebhookPayload struct {
	Amount          string `json:"amount"`
	ReferenceNumber string `json:"referenceNumber"`
	From            string `json:"from"`
	VPA             string `json:"vpa"`
}

// API request/response for initiating payment from frontend
type InitiatePaymentRequest struct {
	OrderID       string `json:"order_id"`
	CustomerName  string `json:"customer_name"`
	CustomerEmail string `json:"customer_email"`
}

type InitiatePaymentResponse struct {
	UroPayOrderId  string `json:"uropay_order_id"`
	UPIString      string `json:"upi_string"`
	QRCode         string `json:"qr_code"`
	AmountInRupees string `json:"amount_in_rupees"`
	PaymentStatus  string `json:"payment_status"`
}

type SubmitReferenceRequest struct {
	OrderID         string `json:"order_id"`
	ReferenceNumber string `json:"reference_number"`
}

type PaymentStatusResponse struct {
	OrderID        string `json:"order_id"`
	PaymentStatus  string `json:"payment_status"`
	UroPayOrderId  string `json:"uropay_order_id,omitempty"`
	UroPayStatus   string `json:"uropay_status,omitempty"`
}
