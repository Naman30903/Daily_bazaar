package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/joho/godotenv"
)

type Config struct {
	SupabaseURL string
	SupabaseKey string
	Port        string
}

func main() {
	// load .env
	if err := godotenv.Load(); err != nil {
		log.Printf("no .env loaded: %v", err)
	}

	config := Config{
		SupabaseURL: os.Getenv("SUPABASE_URL"),
		SupabaseKey: os.Getenv("SUPABASE_KEY"),
		Port:        getEnv("PORT", "8080"),
	}

	if config.SupabaseURL == "" || config.SupabaseKey == "" {
		log.Fatal("SUPABASE_URL and SUPABASE_KEY must be set in the environment (see .env)")
	}

	// Set up routes
	mux := http.NewServeMux()
	mux.HandleFunc("/health", loggingMiddleware(healthCheckHandler(config)))
	mux.HandleFunc("/api/supabase-test", loggingMiddleware(supabaseTestHandler(config)))

	// Create server
	server := &http.Server{
		Addr:         ":" + config.Port,
		Handler:      mux,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	log.Printf("Server starting on port %s...\n", config.Port)
	if err := server.ListenAndServe(); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}

// loggingMiddleware logs HTTP requests
func loggingMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		log.Printf("%s %s from %s", r.Method, r.URL.Path, r.RemoteAddr)
		next(w, r)
		log.Printf("Completed in %v", time.Since(start))
	}
}

// healthCheckHandler returns a simple health check
func healthCheckHandler(config Config) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		fmt.Fprintf(w, `{"status":"ok","timestamp":"%s"}`, time.Now().Format(time.RFC3339))
	}
}

// supabaseTestHandler tests the Supabase connection
func supabaseTestHandler(config Config) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		endpoint := fmt.Sprintf("%s/rest/v1/", config.SupabaseURL)
		req, err := http.NewRequest(http.MethodGet, endpoint, nil)
		if err != nil {
			http.Error(w, fmt.Sprintf("failed to build request: %v", err), http.StatusInternalServerError)
			return
		}

		req.Header.Set("Authorization", "Bearer "+config.SupabaseKey)
		req.Header.Set("apikey", config.SupabaseKey)
		req.Header.Set("Accept", "application/json")

		client := &http.Client{Timeout: 10 * time.Second}
		resp, err := client.Do(req)
		if err != nil {
			http.Error(w, fmt.Sprintf("request failed: %v", err), http.StatusServiceUnavailable)
			return
		}
		defer resp.Body.Close()

		body, _ := io.ReadAll(io.LimitReader(resp.Body, 4096))

		w.Header().Set("Content-Type", "application/json")
		if resp.StatusCode >= 200 && resp.StatusCode < 300 {
			w.WriteHeader(http.StatusOK)
			fmt.Fprintf(w, `{"status":"connected","supabase_status":"%s","message":"Connection OK"}`, resp.Status)
		} else {
			w.WriteHeader(http.StatusServiceUnavailable)
			fmt.Fprintf(w, `{"status":"error","supabase_status":"%s","body":"%s"}`, resp.Status, string(body))
		}
	}
}

// getEnv returns an environment variable or a default value
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
