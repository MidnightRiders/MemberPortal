package cookie_test

import (
	"bytes"
	"context"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/MidnightRiders/MemberPortal/server/internal/cookie"
	"github.com/MidnightRiders/MemberPortal/server/internal/testhelpers"
)

func TestMiddleware(t *testing.T) {
	testCases := []struct {
		it string

		handler http.HandlerFunc

		expectedCookies []http.Cookie
	}{
		{
			it: "works fine with no cookies added",

			handler: http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				w.WriteHeader(http.StatusOK)
			}),

			expectedCookies: []http.Cookie{},
		},
		{
			it: "adds a cookie",

			handler: http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				cookie.Add(r.Context(), http.Cookie{
					Name:  "test",
					Value: "test",
				})
			}),

			expectedCookies: []http.Cookie{
				{
					Name:  "test",
					Value: "test",
				},
			},
		},
		{
			it: "adds multiple",

			handler: http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				cookie.Add(r.Context(), http.Cookie{
					Name:  "foo",
					Value: "bar",
				}, http.Cookie{
					Name:  "bat",
					Value: "baz",
				})
			}),

			expectedCookies: []http.Cookie{
				{
					Name:  "foo",
					Value: "bar",
				}, {
					Name:  "bat",
					Value: "baz",
				},
			},
		},
	}

	t.Run("parallel group", func(g *testing.T) {
		for _, tc := range testCases {
			testCase := tc

			g.Run(testCase.it, func(test *testing.T) {
				test.Parallel()

				w := httptest.NewRecorder()
				r, _ := http.NewRequestWithContext(context.Background(), "GET", "/", bytes.NewReader([]byte("")))
				cookie.Middleware(testCase.handler).ServeHTTP(w, r)
				res := w.Result()
				defer res.Body.Close()

				testhelpers.AssertEqualCookies(test, testCase.expectedCookies, res.Cookies())
			})
		}
	})
}
