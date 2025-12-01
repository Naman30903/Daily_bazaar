package router

import (
	"net/http"

	"github.com/namanjain.3009/daily_bazaar/internal/handlers"
	"github.com/namanjain.3009/daily_bazaar/internal/middleware"
)

func SetupRoutes(
	authHandler *handlers.AuthHandler,
	productHandler *handlers.ProductHandler,
	categoryHandler *handlers.CategoryHandler,
	orderHandler *handlers.OrderHandler,
	productImageHandler *handlers.ProductImageHandler,
	authMiddleware *middleware.AuthMiddleware,
	adminMiddleware *middleware.AdminMiddleware,
) *http.ServeMux {
	mux := http.NewServeMux()

	// Auth routes (public)
	mux.HandleFunc("POST /api/auth/register", authHandler.Register)
	mux.HandleFunc("POST /api/auth/login", authHandler.Login)

	// Category routes (public)
	mux.HandleFunc("GET /api/categories", categoryHandler.GetAllCategories)
	mux.HandleFunc("GET /api/categories/root", categoryHandler.GetRootCategories)
	mux.HandleFunc("GET /api/categories/by-slug/{slug}", categoryHandler.GetCategoryBySlug)
	mux.HandleFunc("GET /api/categories/subcategories/{parentId}", categoryHandler.GetSubcategories)
	mux.HandleFunc("GET /api/categories/{id}", categoryHandler.GetCategoryByID)

	// Category routes (admin only)
	mux.Handle("POST /api/categories", authMiddleware.Authenticate(adminMiddleware.RequireAdmin(http.HandlerFunc(categoryHandler.CreateCategory))))
	mux.Handle("PUT /api/categories/{id}", authMiddleware.Authenticate(adminMiddleware.RequireAdmin(http.HandlerFunc(categoryHandler.UpdateCategory))))
	mux.Handle("DELETE /api/categories/{id}", authMiddleware.Authenticate(adminMiddleware.RequireAdmin(http.HandlerFunc(categoryHandler.DeleteCategory))))

	// Product routes (public)
	mux.HandleFunc("GET /api/products", productHandler.GetAllProducts)
	mux.HandleFunc("GET /api/products/search", productHandler.SearchProducts)
	mux.HandleFunc("GET /api/products/{id}", productHandler.GetProductByID)
	mux.HandleFunc("GET /api/products/category/{categoryId}", productHandler.GetProductsByCategory)

	// Product routes (admin only)
	mux.Handle("POST /api/products", authMiddleware.Authenticate(adminMiddleware.RequireAdmin(http.HandlerFunc(productHandler.CreateProduct))))
	mux.Handle("PUT /api/products/{id}", authMiddleware.Authenticate(adminMiddleware.RequireAdmin(http.HandlerFunc(productHandler.UpdateProduct))))
	mux.Handle("DELETE /api/products/{id}", authMiddleware.Authenticate(adminMiddleware.RequireAdmin(http.HandlerFunc(productHandler.DeleteProduct))))

	// Product Image routes (public)
	mux.HandleFunc("GET /api/products/{productId}/images", productImageHandler.GetProductImages)
	mux.HandleFunc("GET /api/product-images/{id}", productImageHandler.GetImageByID)

	// Product Image routes (admin only)
	mux.Handle("POST /api/products/{productId}/images", authMiddleware.Authenticate(adminMiddleware.RequireAdmin(http.HandlerFunc(productImageHandler.AddImage))))
	mux.Handle("POST /api/products/{productId}/images/bulk", authMiddleware.Authenticate(adminMiddleware.RequireAdmin(http.HandlerFunc(productImageHandler.AddMultipleImages))))
	mux.Handle("PUT /api/product-images/{id}", authMiddleware.Authenticate(adminMiddleware.RequireAdmin(http.HandlerFunc(productImageHandler.UpdateImage))))
	mux.Handle("PUT /api/products/{productId}/images/reorder", authMiddleware.Authenticate(adminMiddleware.RequireAdmin(http.HandlerFunc(productImageHandler.ReorderImages))))
	mux.Handle("PUT /api/products/{productId}/images/{imageId}/primary", authMiddleware.Authenticate(adminMiddleware.RequireAdmin(http.HandlerFunc(productImageHandler.SetPrimaryImage))))
	mux.Handle("DELETE /api/product-images/{id}", authMiddleware.Authenticate(adminMiddleware.RequireAdmin(http.HandlerFunc(productImageHandler.DeleteImage))))
	mux.Handle("DELETE /api/products/{productId}/images", authMiddleware.Authenticate(adminMiddleware.RequireAdmin(http.HandlerFunc(productImageHandler.DeleteAllProductImages))))

	// Order routes (authenticated users)
	mux.Handle("POST /api/orders", authMiddleware.Authenticate(http.HandlerFunc(orderHandler.CreateOrder)))
	mux.Handle("GET /api/orders/my", authMiddleware.Authenticate(http.HandlerFunc(orderHandler.GetMyOrders)))
	mux.Handle("GET /api/orders/{id}", authMiddleware.Authenticate(http.HandlerFunc(orderHandler.GetOrderByID)))
	mux.Handle("POST /api/orders/{id}/cancel", authMiddleware.Authenticate(http.HandlerFunc(orderHandler.CancelOrder)))

	// Order routes (admin only)
	mux.Handle("GET /api/orders", authMiddleware.Authenticate(adminMiddleware.RequireAdmin(http.HandlerFunc(orderHandler.GetAllOrders))))
	mux.Handle("PUT /api/orders/{id}/status", authMiddleware.Authenticate(adminMiddleware.RequireAdmin(http.HandlerFunc(orderHandler.UpdateOrderStatus))))

	return mux
}
