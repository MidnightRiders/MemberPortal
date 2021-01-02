package model

import (
	"context"

	"github.com/MidnightRiders/MemberPortal/server/internal/auth"
)

var UserColumns string = "uuid, email, username, first_name, last_name, address1, address2, city, province, postal_code, country, membership_number"

type User struct {
	UUID             string        `json:"uuid"`
	Username         string        `json:"username"`
	Email            string        `json:"email"`
	FirstName        string        `json:"firstName"`
	LastName         string        `json:"lastName"`
	Address1         string        `json:"address1"`
	Address2         *string       `json:"address2"`
	City             string        `json:"city"`
	Province         *string       `json:"province"`
	PostalCode       string        `json:"postalCode"`
	Country          string        `json:"country"`
	Admin            bool          `json:"admin"`
	MembershipNumber int           `json:"membershipNumber"`
	Memberships      []*Membership `json:"memberships"`
}

func (u *User) Redact(ctx context.Context) {
	info := auth.FromContext(ctx)
	if info.IsAdmin {
		return
	}

	u.Address1 = ""
	u.Address2 = nil
	u.City = ""
	u.Province = nil
	u.PostalCode = ""
	u.Country = ""
}

func UserFromRow(ctx context.Context, row scannable) *User {
	user := &User{}
	row.Scan(
		&user.UUID,
		&user.Email,
		&user.Username,
		&user.FirstName,
		&user.LastName,
		&user.MembershipNumber,

		// Admin-only
		&user.Address1,
		&user.Address2,
		&user.City,
		&user.Province,
		&user.PostalCode,
		&user.Country,
	)
	if user.UUID == "" {
		return nil
	}

	user.Redact(ctx)
	return user
}
