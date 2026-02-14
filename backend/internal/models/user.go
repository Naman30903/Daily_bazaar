package models

import "time"

type User struct {
	ID              string                 `json:"id"`
	Email           string                 `json:"email"`
	Password        string                 `json:"password"`
	FullName        string                 `json:"full_name"`
	Phone           string                 `json:"phone,omitempty"`
	Metadata        map[string]interface{} `json:"metadata,omitempty"`
	CreatedAt       time.Time              `json:"created_at,omitempty"`
	IsAdmin         bool                   `json:"is_admin,omitempty"`
	ResetOTP        string                 `json:"reset_otp,omitempty"`
	ResetOTPExpiry  *time.Time             `json:"reset_otp_expiry,omitempty"`
}

type RegisterRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
	FullName string `json:"full_name"`
	Phone    string `json:"phone,omitempty"`
}

type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type AuthResponse struct {
	Token string `json:"token"`
	User  User   `json:"user"`
}

type ForgotPasswordRequest struct {
	Email string `json:"email"`
}

type ResetPasswordRequest struct {
	Email       string `json:"email"`
	OTP         string `json:"otp"`
	NewPassword string `json:"new_password"`
}
