package main

import (
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"

	"github.com/namanjain.3009/daily_bazaar/internal/config"
	"github.com/namanjain.3009/daily_bazaar/internal/handlers"
)

func main() {
	_ = godotenv.Load()

	cfg := config.Load()

	gin.SetMode(gin.ReleaseMode)
	r := gin.New()
	r.Use(gin.Logger(), gin.Recovery())

	// Public auth
	r.POST("/register", gin.WrapF(handlers.RegisterHandler))
	r.POST("/login", gin.WrapF(handlers.LoginHandler))

	// Products & categories
	r.GET("/products", gin.WrapF(handlers.ListProductsHandler))
	r.GET("/products/:id", gin.WrapF(handlers.GetProductHandler))
	r.GET("/categories", gin.WrapF(handlers.ListCategoriesHandler))

	// Cart & orders
	r.POST("/cart", gin.WrapF(handlers.AddToCartHandler))
	r.GET("/cart", gin.WrapF(handlers.GetCartHandler))
	r.POST("/orders", gin.WrapF(handlers.CreateOrderHandler))
	r.GET("/orders/:id", gin.WrapF(handlers.GetOrderHandler))

	// Delivery
	r.GET("/delivery/:id", gin.WrapF(handlers.TrackDeliveryHandler))

	port := cfg.Port
	if port == "" {
		port = os.Getenv("PORT")
		if port == "" {
			port = "8080"
		}
	}

	if err := r.Run(":" + port); err != nil {
		log.Fatalf("server failed: %v", err)
	}
}
