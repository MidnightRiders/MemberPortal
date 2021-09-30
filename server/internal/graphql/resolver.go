//go:generate go run github.com/99designs/gqlgen
package graphql

import (
	"database/sql"

	"github.com/MidnightRiders/MemberPortal/server/internal/env"
)

// This file will not be regenerated automatically.
//
// It serves as dependency injection for your app, add any dependencies you require here.

type Resolver struct {
	DB     *sql.DB
	Domain string
	Env    env.Env
}
