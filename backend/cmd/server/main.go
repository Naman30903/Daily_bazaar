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
	userAddressRepo := repository.NewUserAddressRepository()

	// Initialize services - UPDATED: ProductService now needs categoryRepo
	authService := services.NewAuthService(userRepo)
	productService := services.NewProductService(productRepo, categoryRepo) // ✅ CHANGED
	categoryService := services.NewCategoryService(categoryRepo)
	orderService := services.NewOrderService(orderRepo, productRepo)
	productImageService := services.NewProductImageService(productImageRepo, productRepo)
	userAddressService := services.NewUserAddressService(userAddressRepo)

	// Initialize handlers
	authHandler := handlers.NewAuthHandler(authService)
	userHandler := handlers.NewUserHandler(userRepo)
	productHandler := handlers.NewProductHandler(productService)
	categoryHandler := handlers.NewCategoryHandler(categoryService)
	orderHandler := handlers.NewOrderHandler(orderService, userRepo)
	productImageHandler := handlers.NewProductImageHandler(productImageService)
	userAddressHandler := handlers.NewUserAddressHandler(userAddressService)

	// Initialize middleware
	authMiddleware := middleware.NewAuthMiddleware(authService)
	adminMiddleware := middleware.NewAdminMiddleware(userRepo)

	// Setup routes
	mux := router.SetupRoutes(
		authHandler,
		userHandler,
		productHandler,
		categoryHandler,
		orderHandler,
		productImageHandler,
		userAddressHandler,
		authMiddleware,
		adminMiddleware,
	)

	// CORS
	cors := middleware.NewCORSMiddleware([]string{
		"http://localhost:3000",
		"http://127.0.0.1:3000",
		"http://localhost:5173",
		"http://127.0.0.1:5173",
		"*",
	})

	handler := cors.Handler(mux)

	log.Printf("Server starting on port %s", cfg.Port)
	_ = http.ListenAndServe(":"+cfg.Port, handler)
}
