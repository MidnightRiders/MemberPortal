package auth

import (
	"context"
	"time"
)

type ctxKey string

var contextKey ctxKey = "auth"

// Info describes the auth state of the current context
type Info struct {
	CurrentMember bool
	Expires       *time.Time
	LoggedIn      bool
	UUID          string
}

// AddToContext adds Info to a given context
func AddToContext(ctx context.Context, info Info) context.Context {
	return context.WithValue(ctx, contextKey, info)
}

// FromContext returns auth data from the given context
func FromContext(ctx context.Context) *Info {
	if info, ok := ctx.Value(contextKey).(Info); ok {
		return &info
	}
	return &Info{}
}
