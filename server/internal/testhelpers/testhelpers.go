package testhelpers

import (
	"bytes"
	"context"
	"net/http"
	"os"
	"strings"
	"testing"
	"time"

	oklog "github.com/oklog/ulid/v2"
	"github.com/stretchr/testify/assert"

	"github.com/MidnightRiders/MemberPortal/server/internal/stubbables"
	"github.com/MidnightRiders/MemberPortal/server/internal/ulid"
)

// ReqParams are params for BuildReq
type ReqParams struct {
	Method  string
	Path    string
	Headers map[string]string
	Cookies []*http.Cookie
	Body    string
}

// BuildReq creates a request quickly for tests
func BuildReq(p ReqParams) *http.Request {
	method := p.Method
	if method == "" {
		method = http.MethodGet
	}
	path := p.Path
	if path == "" {
		path = "/"
	}
	if strings.HasPrefix(path, "/") {
		path = "https://members.midnightriders.com" + path
	}
	req, _ := http.NewRequestWithContext(context.Background(), method, path, bytes.NewReader([]byte(p.Body)))
	if p.Cookies != nil {
		for _, cookie := range p.Cookies {
			req.AddCookie(cookie)
		}
	}
	if p.Headers != nil {
		for key, val := range p.Headers {
			req.Header.Add(key, val)
		}
	}
	return req
}

func createAssertionResultCapturer() (*bool, func(bool) bool) {
	value := true
	val := &value
	return val, func(result bool) bool {
		if !result {
			*val = false
		}
		return result
	}
}

// AssertEqualCookie compares a given cookie with a cookie returned through a ResponseWriter
func AssertEqualCookie(test *testing.T, expectedCookie http.Cookie, receivedCookie *http.Cookie) bool {
	result, capture := createAssertionResultCapturer()
	if capture(assert.NotNil(test, receivedCookie)) {
		if expectedCookie.Value == "match-ulid" && receivedCookie.Value != "" {
			expectedCookie.Value = receivedCookie.Value
		}
		capture(assert.Equal(test, expectedCookie.Name, receivedCookie.Name))
		capture(assert.Equal(test, expectedCookie.Domain, receivedCookie.Domain))
		capture(assert.Equal(test, expectedCookie.Value, receivedCookie.Value))
		capture(assert.Equal(test, expectedCookie.Expires, receivedCookie.Expires))
		capture(assert.Equal(test, expectedCookie.SameSite, receivedCookie.SameSite))
		capture(assert.Equal(test, expectedCookie.Secure, receivedCookie.Secure))
	}
	return *result
}

// AssertEqualCookies compares an array of expected cookies with a received array of cookie
// pointers that were returned from a ResponseWriter.
func AssertEqualCookies(test *testing.T, expectedCookies []http.Cookie, receivedCookies []*http.Cookie) bool {
	result, capture := createAssertionResultCapturer()
	capture(assert.Len(test, receivedCookies, len(expectedCookies)))
	for i, ck := range expectedCookies {
		if capture(assert.GreaterOrEqual(
			test, len(receivedCookies), i+1, "expected received cookies to have length of at least", i+1),
		) {
			capture(AssertEqualCookie(test, ck, receivedCookies[i]))
		}
	}
	return *result
}

// StubTimeNow stubs stubbables.TimeNow and returns the teardown
func StubTimeNow(tm *time.Time) func() {
	var t time.Time
	if tm == nil {
		t = time.Date(2020, 7, 29, 8, 29, 0, 0, time.UTC)
	} else {
		t = *tm
	}
	tn := stubbables.TimeNow
	stubbables.TimeNow = func() time.Time {
		return t
	}
	return func() {
		stubbables.TimeNow = tn
	}
}

// StubRandomStr stubs stubbables.RandomStr and returns the teardown
func StubRandomStr(value string) func() {
	rs := stubbables.RandomStr
	stubbables.RandomStr = func(int) string {
		return value
	}
	return func() {
		stubbables.RandomStr = rs
	}
}

// StubEnvVar stubs an env var and returns a teardown
func StubEnvVar(key string, val string) func() {
	v := os.Getenv(key)
	err := os.Setenv(key, val)
	if err != nil {
		panic(err)
	}
	return func() {
		err := os.Setenv(key, v)
		if err != nil {
			panic(err)
		}
	}
}

type stubbedULIDGenerator struct {
	val oklog.ULID
}

func (g *stubbedULIDGenerator) New() oklog.ULID {
	return g.val
}

func (g *stubbedULIDGenerator) String() string {
	return g.val.String()
}

// StubULIDGenerator stubs the ULID Generator to return a predicatable string
func StubULIDGenerator(val string) func() {
	v := ulid.NewGenerator
	u, err := oklog.Parse(val)
	if err != nil {
		panic(err)
	}
	ulid.NewGenerator = func() ulid.Generator {
		return &stubbedULIDGenerator{val: u}
	}
	return func() {
		ulid.NewGenerator = v
	}
}
