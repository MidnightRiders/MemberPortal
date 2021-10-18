// Package ulid provides convenience functions around oklog/ulid
// to easily generate ULIDs and stringify them
package ulid

import (
	"crypto/rand"
	"time"

	oklog "github.com/oklog/ulid/v2"
)

type Generator interface {
	New() oklog.ULID
	String() string
}

type generator struct {
	entropy *oklog.MonotonicEntropy
}

func (g *generator) New() oklog.ULID {
	return oklog.MustNew(oklog.Timestamp(time.Now()), g.entropy)
}

func (g *generator) String() string {
	return g.New().String()
}

var NewGenerator = func() Generator {
	entropy := oklog.Monotonic(rand.Reader, 0)
	return &generator{entropy: entropy}
}
