//go:generate go run github.com/99designs/gqlgen
package graphql

import (
	"gorm.io/gorm"

	"github.com/MidnightRiders/MemberPortal/server/internal/env"
)

// This file will not be regenerated automatically.
//
// It serves as dependency injection for your app, add any dependencies you require here.

type Resolver struct {
	DB     *gorm.DB
	Domain string
	Env    env.Env
}
