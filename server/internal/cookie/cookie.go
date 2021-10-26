package cookie

import (
	"context"
	"net/http"

	"github.com/sirupsen/logrus"
)

type ctxKey string

var contextKey ctxKey = "cookies"

// Middleware allows for setting cookies in
func Middleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var cookies []http.Cookie
		next.ServeHTTP(w, r.WithContext(AddToContext(r.Context(), &cookies)))

		for _, ck := range cookies {
			cookie := ck
			http.SetCookie(w, &cookie)
		}
	})
}

// AddToContext adds a clice of Cookies to a given context
func AddToContext(ctx context.Context, cookies *[]http.Cookie) context.Context {
	return context.WithValue(ctx, contextKey, cookies)
}

// Add takes a context and adds a cookie to it
func Add(ctx context.Context, ck ...http.Cookie) {
	ptr, ok := ctx.Value(contextKey).(*[]http.Cookie)
	if !ok {
		logrus.Error("Could not coerce context Cookies to pointer")
	}
	cookies := append(*ptr, ck...)
	*ptr = cookies
}
