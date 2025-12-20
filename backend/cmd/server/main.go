package main

import (
	"log"
	"net/http"

	"github.com/namanjain.3009/daily_bazaar/internal/config"
	"github.com/namanjain.3009/daily_bazaar/internal/handlers"
	"github.com/namanjain.3009/daily_bazaar/internal/middleware"
	"github.com/namanjain.3009/daily_bazaar/internal/repository"
	"github.com/namanjain.3009/daily_bazaar/internal/router"
	"github.com/namanjain.3009/daily_bazaar/internal/services"
)

func main() {
	cfg, err := config.Load()
	if err != nil {
		log.Fatal(err)
	}

	// Initialize repositories
	userRepo := repository.NewUserRepository()
	productRepo := repository.NewProductRepository()
	categoryRepo := repository.NewCategoryRepository()
	orderRepo := repository.NewOrderRepository()
	productImageRepo := repository.NewProductImageRepository()

	// Initialize services
	authService := services.NewAuthService(userRepo)
	productService := services.NewProductService(productRepo)
	categoryService := services.NewCategoryService(categoryRepo)
	orderService := services.NewOrderService(orderRepo, productRepo)
	productImageService := services.NewProductImageService(productImageRepo, productRepo)

	// Initialize handlers
	authHandler := handlers.NewAuthHandler(authService)
	productHandler := handlers.NewProductHandler(productService)
	categoryHandler := handlers.NewCategoryHandler(categoryService)
	orderHandler := handlers.NewOrderHandler(orderService, userRepo)
	productImageHandler := handlers.NewProductImageHandler(productImageService)

	// Initialize middleware
	authMiddleware := middleware.NewAuthMiddleware(authService)
	adminMiddleware := middleware.NewAdminMiddleware(userRepo)

	// Setup routes
	mux := router.SetupRoutes(
		authHandler,
		productHandler,
		categoryHandler,
		orderHandler,
		productImageHandler,
		authMiddleware,
		adminMiddleware,
	)

	log.Printf("Server starting on port %s", cfg.Port)
	if err := http.ListenAndServe(":"+cfg.Port, mux); err != nil {
		log.Fatal(err)
	}
}
