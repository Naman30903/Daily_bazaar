package middleware

import (
	"net/http"

	"github.com/namanjain.3009/daily_bazaar/internal/repository"
)

type AdminMiddleware struct {
	userRepo *repository.UserRepository
}

func NewAdminMiddleware(userRepo *repository.UserRepository) *AdminMiddleware {
	return &AdminMiddleware{userRepo: userRepo}
}

func (m *AdminMiddleware) RequireAdmin(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		claims := GetUserFromContext(r.Context())
		if claims == nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		// Fetch user from database to check admin status
		user, err := m.userRepo.GetUserByID(claims.UserID)
		if err != nil {
			http.Error(w, "User not found", http.StatusUnauthorized)
			return
		}

		if !user.IsAdmin {
			http.Error(w, "Admin access required", http.StatusForbidden)
			return
		}

		next.ServeHTTP(w, r)
	})
}
