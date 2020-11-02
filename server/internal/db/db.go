package db

import (
	"context"
	"database/sql"
	"errors"
	"net/http"
	"os"

	// Compatibility layer for database/sql
	_ "github.com/jackc/pgx/stdlib"
)

// CtxKey is the interface for db context keys
type CtxKey string

// Context Key for storing db and conn on Context
const (
	DBKey CtxKey = "db"
)

// CanServeHTTP means it's either a HandlerFunc or a Server
type CanServeHTTP interface {
	ServeHTTP(http.ResponseWriter, *http.Request)
}

// FromContext gets the DB from a given context
func FromContext(ctx context.Context) (*sql.DB, error) {
	if db, ok := ctx.Value(DBKey).(*sql.DB); ok {
		return db, nil
	}
	return nil, errors.New("Could not retrieve database from context")
}

// Connect connects to database and gives back necessary info
func Connect() (*sql.DB, func(CanServeHTTP) http.HandlerFunc, error) {
	db, err := sql.Open("pgx", os.Getenv("DATABASE_URL"))
	if err != nil {
		return nil, nil, err
	}

	middleware := func(next CanServeHTTP) http.HandlerFunc {
		return http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
			ctx := req.Context()
			ctx = context.WithValue(ctx, DBKey, db)
			next.ServeHTTP(w, req.WithContext(ctx))
		})
	}

	return db, middleware, nil
}
