package services

import (
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/namanjain.3009/daily_bazaar/internal/models"
	"github.com/namanjain.3009/daily_bazaar/internal/repository"
)

type OrderService struct {
	orderRepo   *repository.OrderRepository
	productRepo *repository.ProductRepository
}

func NewOrderService(orderRepo *repository.OrderRepository, productRepo *repository.ProductRepository) *OrderService {
	return &OrderService{
		orderRepo:   orderRepo,
		productRepo: productRepo,
	}
}

func (s *OrderService) CreateOrder(userID string, req *models.CreateOrderRequest) (*models.Order, error) {
	if len(req.Items) == 0 {
		return nil, errors.New("order must contain at least one item")
	}

	if req.ShippingAddress == nil {
		return nil, errors.New("shipping address is required")
	}

	// Calculate order totals
	var subtotalCents int64 = 0
	orderItems := make([]models.OrderItem, 0, len(req.Items))

	for _, item := range req.Items {
		if item.Quantity <= 0 {
			return nil, errors.New("item quantity must be positive")
		}

		// Fetch product to get current price
		product, err := s.productRepo.GetProductByID(item.ProductID)
		if err != nil {
			return nil, errors.New("product not found: " + item.ProductID)
		}

		if !product.Active {
			return nil, errors.New("product is not available: " + product.Name)
		}

		if product.Stock < item.Quantity {
			return nil, errors.New("insufficient stock for product: " + product.Name)
		}

		itemTotal := product.PriceCents * int64(item.Quantity)
		subtotalCents += itemTotal

		orderItems = append(orderItems, models.OrderItem{
			ID:             uuid.New().String(),
			ProductID:      item.ProductID,
			Quantity:       item.Quantity,
			UnitPriceCents: product.PriceCents,
		})
	}

	// Calculate shipping and tax (you can customize these calculations)
	var shippingCents int64 = 0
	if subtotalCents < 50000 { // Free shipping over $500
		shippingCents = 999 // $9.99 shipping
	}

	taxCents := subtotalCents * 10 / 100 // 10% tax
	totalCents := subtotalCents + shippingCents + taxCents

	// Create order
	order := &models.Order{
		ID:              uuid.New().String(),
		UserID:          userID,
		SubtotalCents:   subtotalCents,
		ShippingCents:   shippingCents,
		TaxCents:        taxCents,
		TotalCents:      totalCents,
		Status:          models.OrderStatusPending,
		PlacedAt:        time.Now(),
		ShippingAddress: req.ShippingAddress,
		PaymentMetadata: req.PaymentMetadata,
	}

	if err := s.orderRepo.CreateOrder(order); err != nil {
		return nil, err
	}

	// Set order ID for items and create them
	for i := range orderItems {
		orderItems[i].OrderID = order.ID
	}

	if err := s.orderRepo.CreateOrderItems(orderItems); err != nil {
		// Attempt to rollback order creation
		s.orderRepo.DeleteOrder(order.ID)
		return nil, errors.New("failed to create order items")
	}

	order.Items = orderItems
	return order, nil
}

func (s *OrderService) GetOrderByID(id string, userID string, isAdmin bool) (*models.Order, error) {
	if id == "" {
		return nil, errors.New("order ID is required")
	}

	order, err := s.orderRepo.GetOrderByID(id)
	if err != nil {
		return nil, err
	}

	// Check if user has access to this order
	if !isAdmin && order.UserID != userID {
		return nil, errors.New("access denied")
	}

	return order, nil
}

func (s *OrderService) GetUserOrders(userID string) ([]models.Order, error) {
	if userID == "" {
		return nil, errors.New("user ID is required")
	}
	return s.orderRepo.GetOrdersByUserID(userID)
}

func (s *OrderService) GetAllOrders(status string, limit, offset int) ([]models.Order, error) {
	// Validate status if provided
	if status != "" && !isValidStatus(status) {
		return nil, errors.New("invalid order status")
	}
	return s.orderRepo.GetAllOrders(status, limit, offset)
}

func (s *OrderService) UpdateOrderStatus(id string, status string) (*models.Order, error) {
	if id == "" {
		return nil, errors.New("order ID is required")
	}

	if !isValidStatus(status) {
		return nil, errors.New("invalid order status")
	}

	// Check if order exists
	existingOrder, err := s.orderRepo.GetOrderByID(id)
	if err != nil {
		return nil, err
	}

	// Validate status transition
	if !isValidStatusTransition(existingOrder.Status, status) {
		return nil, errors.New("invalid status transition")
	}

	return s.orderRepo.UpdateOrderStatus(id, status)
}

func (s *OrderService) CancelOrder(id string, userID string, isAdmin bool) (*models.Order, error) {
	if id == "" {
		return nil, errors.New("order ID is required")
	}

	order, err := s.orderRepo.GetOrderByID(id)
	if err != nil {
		return nil, err
	}

	// Check if user has access to this order
	if !isAdmin && order.UserID != userID {
		return nil, errors.New("access denied")
	}

	// Can only cancel pending or confirmed orders
	if order.Status != models.OrderStatusPending && order.Status != models.OrderStatusConfirmed {
		return nil, errors.New("order cannot be cancelled")
	}

	return s.orderRepo.UpdateOrderStatus(id, models.OrderStatusCancelled)
}

func isValidStatus(status string) bool {
	validStatuses := []string{
		models.OrderStatusPending,
		models.OrderStatusConfirmed,
		models.OrderStatusProcessing,
		models.OrderStatusShipped,
		models.OrderStatusDelivered,
		models.OrderStatusCancelled,
	}
	for _, s := range validStatuses {
		if s == status {
			return true
		}
	}
	return false
}

func isValidStatusTransition(from, to string) bool {
	transitions := map[string][]string{
		models.OrderStatusPending:    {models.OrderStatusConfirmed, models.OrderStatusCancelled},
		models.OrderStatusConfirmed:  {models.OrderStatusProcessing, models.OrderStatusCancelled},
		models.OrderStatusProcessing: {models.OrderStatusShipped, models.OrderStatusCancelled},
		models.OrderStatusShipped:    {models.OrderStatusDelivered},
		models.OrderStatusDelivered:  {},
		models.OrderStatusCancelled:  {},
	}

	allowedTransitions, exists := transitions[from]
	if !exists {
		return false
	}

	for _, allowed := range allowedTransitions {
		if allowed == to {
			return true
		}
	}
	return false
}
