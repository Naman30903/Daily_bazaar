package config

import (
	"fmt"
	"log"
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
	// Attempt to load .env for local development. Failures are non-fatal
	// because production environments (Render, etc.) provide env vars.
	if err := godotenv.Load("../../.env"); err != nil {
		if err2 := godotenv.Load(".env"); err2 != nil {
			log.Printf(".env not found (this is OK in production): tried '../../.env' and '.env' - %v", err)
		}
	}

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
