package auth

import (
	"context"

	"github.com/MidnightRiders/MemberPortal/server/internal/graphql/model"
)

func Redact(ctx context.Context, u *model.User) *model.User {
	info := FromContext(ctx)
	if info.IsAdmin {
		return u
	}

	redacted := *u
	redacted.Address1 = ""
	redacted.Address2 = nil
	redacted.City = ""
	redacted.Province = nil
	redacted.PostalCode = ""
	redacted.Country = ""

	return &redacted
}
