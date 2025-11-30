package router

import (
	"net/http"

	"github.com/namanjain.3009/daily_bazaar/internal/handlers"
	"github.com/namanjain.3009/daily_bazaar/internal/middleware"
)

func SetupRoutes(
	authHandler *handlers.AuthHandler,
	productHandler *handlers.ProductHandler,
	authMiddleware *middleware.AuthMiddleware,
	adminMiddleware *middleware.AdminMiddleware,
) *http.ServeMux {
	mux := http.NewServeMux()

	// Auth routes (public)
	mux.HandleFunc("POST /api/auth/register", authHandler.Register)
	mux.HandleFunc("POST /api/auth/login", authHandler.Login)

	// Product routes (public)
	mux.HandleFunc("GET /api/products", productHandler.GetAllProducts)
	mux.HandleFunc("GET /api/products/search", productHandler.SearchProducts)
	mux.HandleFunc("GET /api/products/{id}", productHandler.GetProductByID)
	mux.HandleFunc("GET /api/products/category/{categoryId}", productHandler.GetProductsByCategory)

	// Product routes (admin only)
	mux.Handle("POST /api/products", authMiddleware.Authenticate(adminMiddleware.RequireAdmin(http.HandlerFunc(productHandler.CreateProduct))))
	mux.Handle("PUT /api/products/{id}", authMiddleware.Authenticate(adminMiddleware.RequireAdmin(http.HandlerFunc(productHandler.UpdateProduct))))
	mux.Handle("DELETE /api/products/{id}", authMiddleware.Authenticate(adminMiddleware.RequireAdmin(http.HandlerFunc(productHandler.DeleteProduct))))

	return mux
}
