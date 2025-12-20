package middleware

import "net/http"

type CORSMiddleware struct {
	AllowedOrigins []string
}

func NewCORSMiddleware(allowedOrigins []string) *CORSMiddleware {
	return &CORSMiddleware{AllowedOrigins: allowedOrigins}
}

func (m *CORSMiddleware) Handler(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		origin := r.Header.Get("Origin")

		allowedOrigin := ""
		if origin != "" {
			// allow any origin if list contains "*"
			for _, o := range m.AllowedOrigins {
				if o == "*" || o == origin {
					allowedOrigin = origin
					if o == "*" {
						allowedOrigin = "*"
					}
					break
				}
			}
		}

		// Set headers (also for non-preflight responses)
		if allowedOrigin != "" {
			w.Header().Set("Access-Control-Allow-Origin", allowedOrigin)
			w.Header().Set("Vary", "Origin")
			w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
			w.Header().Set("Access-Control-Allow-Headers", "Authorization, Content-Type, Accept")
			w.Header().Set("Access-Control-Max-Age", "86400")
		}

		// Preflight request
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}

		next.ServeHTTP(w, r)
	})
}
