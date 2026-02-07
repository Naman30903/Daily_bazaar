package config

import (
	"fmt"
	"os"
	"strings"

	"github.com/joho/godotenv"
)

type Config struct {
	Port        string
	SupabaseURL string
	SupabaseKey string
	JWTSecret   string
}

func Load() (*Config, error) {
	// Try to load .env from repo root first (for development)
	_ = godotenv.Load("../../.env")
	// If that fails, try current directory
	_ = godotenv.Load(".env")
	// In production (e.g., Render), env vars are set directly, so .env is optional

	cfg := &Config{
		Port:        strings.TrimSpace(os.Getenv("PORT")),
		SupabaseURL: strings.TrimSpace(os.Getenv("SUPABASE_URL")),
		SupabaseKey: strings.TrimSpace(os.Getenv("SUPABASE_KEY")),
		JWTSecret:   strings.TrimSpace(os.Getenv("JWT_SECRET")),
	}

	if cfg.Port == "" {
		cfg.Port = "8080"
	}

	// basic required checks
	missing := []string{}
	if cfg.SupabaseURL == "" {
		missing = append(missing, "SUPABASE_URL")
	}
	if cfg.SupabaseKey == "" {
		missing = append(missing, "SUPABASE_KEY")
	}
	if cfg.JWTSecret == "" {
		missing = append(missing, "JWT_SECRET")
	}
	if len(missing) > 0 {
		return nil, fmt.Errorf("missing required env vars: %s", strings.Join(missing, ", "))
	}

	return cfg, nil
}
