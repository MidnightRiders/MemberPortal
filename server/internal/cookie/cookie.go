package cookie

import (
	"context"
	"net/http"
)

type ctxKey string

var contextKey ctxKey = "cookies"

// Middleware allows for setting cookies in
func Middleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		cookies := []http.Cookie{}

		next.ServeHTTP(w, r.WithContext(context.WithValue(r.Context(), contextKey, &cookies)))

		for _, ck := range cookies {
			http.SetCookie(w, &ck)
		}
	})
}

// Add takes a context and adds a cookie to it
func Add(ctx context.Context, ck ...http.Cookie) {
	ptr := ctx.Value(contextKey).(*[]http.Cookie)
	cookies := append(*ptr, ck...)
	*ptr = cookies
}
