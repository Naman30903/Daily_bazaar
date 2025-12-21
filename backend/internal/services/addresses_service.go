package services

import (
	"errors"
	"regexp"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/namanjain.3009/daily_bazaar/internal/models"
	"github.com/namanjain.3009/daily_bazaar/internal/repository"
)

type UserAddressService struct {
	repo *repository.UserAddressRepository
}

func NewUserAddressService(repo *repository.UserAddressRepository) *UserAddressService {
	return &UserAddressService{repo: repo}
}

var (
	reINPincode = regexp.MustCompile(`^[1-9][0-9]{5}$`)
	reINPhone   = regexp.MustCompile(`^(\+91[- ]?)?[6-9][0-9]{9}$`)
)

func (s *UserAddressService) List(userID string) ([]models.UserAddress, error) {
	if userID == "" {
		return nil, errors.New("user ID is required")
	}
	return s.repo.ListByUserID(userID)
}

func (s *UserAddressService) Create(userID string, req *models.CreateUserAddressRequest) (*models.UserAddress, error) {
	if userID == "" {
		return nil, errors.New("user ID is required")
	}
	if strings.TrimSpace(req.FullName) == "" {
		return nil, errors.New("full_name is required")
	}
	if strings.TrimSpace(req.AddressLine1) == "" {
		return nil, errors.New("address_line1 is required")
	}
	if strings.TrimSpace(req.City) == "" {
		return nil, errors.New("city is required")
	}
	if strings.TrimSpace(req.State) == "" {
		return nil, errors.New("state is required")
	}
	if !reINPincode.MatchString(strings.TrimSpace(req.Pincode)) {
		return nil, errors.New("invalid pincode (India): must be 6 digits")
	}
	if !reINPhone.MatchString(strings.TrimSpace(req.Phone)) {
		return nil, errors.New("invalid phone (India): must be valid Indian mobile")
	}

	addr := &models.UserAddress{
		ID:           uuid.New().String(),
		UserID:       userID,
		Label:        req.Label,
		IsDefault:    req.IsDefault,
		FullName:     req.FullName,
		Phone:        req.Phone,
		AddressLine1: req.AddressLine1,
		AddressLine2: req.AddressLine2,
		Landmark:     req.Landmark,
		City:         req.City,
		District:     req.District,
		State:        req.State,
		Pincode:      req.Pincode,
		CountryCode:  "IN",
		CreatedAt:    time.Now(),
		UpdatedAt:    time.Now(),
	}

	// If setting default, unset any old default (unique index also protects)
	if addr.IsDefault {
		if err := s.unsetDefaultForUser(userID); err != nil {
			return nil, err
		}
	}

	if err := s.repo.Create(addr); err != nil {
		return nil, err
	}

	return addr, nil
}

func (s *UserAddressService) Update(userID, addressID string, req *models.UpdateUserAddressRequest) (*models.UserAddress, error) {
	if userID == "" {
		return nil, errors.New("user ID is required")
	}
	if addressID == "" {
		return nil, errors.New("address ID is required")
	}

	existing, err := s.repo.GetByID(addressID)
	if err != nil {
		return nil, err
	}
	if existing.UserID != userID {
		return nil, errors.New("access denied")
	}

	updates := map[string]interface{}{}

	if req.Label != nil {
		updates["label"] = *req.Label
	}
	if req.IsDefault != nil {
		if *req.IsDefault {
			if err := s.unsetDefaultForUser(userID); err != nil {
				return nil, err
			}
		}
		updates["is_default"] = *req.IsDefault
	}
	if req.FullName != nil {
		if strings.TrimSpace(*req.FullName) == "" {
			return nil, errors.New("full_name cannot be empty")
		}
		updates["full_name"] = *req.FullName
	}
	if req.Phone != nil {
		if !reINPhone.MatchString(strings.TrimSpace(*req.Phone)) {
			return nil, errors.New("invalid phone (India): must be valid Indian mobile")
		}
		updates["phone"] = *req.Phone
	}
	if req.AddressLine1 != nil {
		if strings.TrimSpace(*req.AddressLine1) == "" {
			return nil, errors.New("address_line1 cannot be empty")
		}
		updates["address_line1"] = *req.AddressLine1
	}
	if req.AddressLine2 != nil {
		updates["address_line2"] = *req.AddressLine2
	}
	if req.Landmark != nil {
		updates["landmark"] = *req.Landmark
	}
	if req.City != nil {
		if strings.TrimSpace(*req.City) == "" {
			return nil, errors.New("city cannot be empty")
		}
		updates["city"] = *req.City
	}
	if req.District != nil {
		updates["district"] = *req.District
	}
	if req.State != nil {
		if strings.TrimSpace(*req.State) == "" {
			return nil, errors.New("state cannot be empty")
		}
		updates["state"] = *req.State
	}
	if req.Pincode != nil {
		if !reINPincode.MatchString(strings.TrimSpace(*req.Pincode)) {
			return nil, errors.New("invalid pincode (India): must be 6 digits")
		}
		updates["pincode"] = *req.Pincode
	}

	updates["country_code"] = "IN"
	updates["updated_at"] = time.Now()

	if len(updates) == 0 {
		return nil, errors.New("no fields to update")
	}

	return s.repo.Update(addressID, updates)
}

func (s *UserAddressService) Delete(userID, addressID string) error {
	if userID == "" {
		return errors.New("user ID is required")
	}
	if addressID == "" {
		return errors.New("address ID is required")
	}

	existing, err := s.repo.GetByID(addressID)
	if err != nil {
		return err
	}
	if existing.UserID != userID {
		return errors.New("access denied")
	}

	return s.repo.Delete(addressID)
}

// unsetDefaultForUser sets all addresses is_default=false for the user.
// (Uses list+update, keeps repository simple.)
func (s *UserAddressService) unsetDefaultForUser(userID string) error {
	addrs, err := s.repo.ListByUserID(userID)
	if err != nil {
		return err
	}
	for _, a := range addrs {
		if a.IsDefault {
			_, err := s.repo.Update(a.ID, map[string]interface{}{
				"is_default": false,
			})
			if err != nil {
				return err
			}
		}
	}
	return nil
}
