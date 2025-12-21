package models

import "time"

type UserAddress struct {
	ID           string    `json:"id"`
	UserID       string    `json:"user_id"`
	Label        string    `json:"label,omitempty"`
	IsDefault    bool      `json:"is_default"`
	FullName     string    `json:"full_name"`
	Phone        string    `json:"phone"`
	AddressLine1 string    `json:"address_line1"`
	AddressLine2 string    `json:"address_line2,omitempty"`
	Landmark     string    `json:"landmark,omitempty"`
	City         string    `json:"city"`
	District     string    `json:"district,omitempty"`
	State        string    `json:"state"`
	Pincode      string    `json:"pincode"`
	CountryCode  string    `json:"country_code"` // always "IN"
	CreatedAt    time.Time `json:"created_at,omitempty"`
	UpdatedAt    time.Time `json:"updated_at,omitempty"`
}

type CreateUserAddressRequest struct {
	Label        string `json:"label,omitempty"`
	IsDefault    bool   `json:"is_default,omitempty"`
	FullName     string `json:"full_name"`
	Phone        string `json:"phone"`
	AddressLine1 string `json:"address_line1"`
	AddressLine2 string `json:"address_line2,omitempty"`
	Landmark     string `json:"landmark,omitempty"`
	City         string `json:"city"`
	District     string `json:"district,omitempty"`
	State        string `json:"state"`
	Pincode      string `json:"pincode"`
}

type UpdateUserAddressRequest struct {
	Label        *string `json:"label,omitempty"`
	IsDefault    *bool   `json:"is_default,omitempty"`
	FullName     *string `json:"full_name,omitempty"`
	Phone        *string `json:"phone,omitempty"`
	AddressLine1 *string `json:"address_line1,omitempty"`
	AddressLine2 *string `json:"address_line2,omitempty"`
	Landmark     *string `json:"landmark,omitempty"`
	City         *string `json:"city,omitempty"`
	District     *string `json:"district,omitempty"`
	State        *string `json:"state,omitempty"`
	Pincode      *string `json:"pincode,omitempty"`
}
