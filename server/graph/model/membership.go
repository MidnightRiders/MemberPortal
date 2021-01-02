package model

import (
	"context"

	"github.com/MidnightRiders/MemberPortal/server/internal/auth"
)

var MembershipColumns string = "uuid, user_uuid, year, type, role"

type Membership struct {
	UUID     string         `json:"uuid"`
	UserUUID string         `json:"userUUID"`
	Year     int            `json:"year"`
	Type     MembershipType `json:"type"`
	Role     auth.Role      `json:"role"`
}

func MembershipFromRow(_ context.Context, row scannable) *Membership {
	m := &Membership{}
	row.Scan(
		&m.UUID,
		&m.Year,
		&m.Type,
		&m.Role,
	)
	if m.UUID == "" {
		return nil
	}
	return m
}
