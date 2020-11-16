package stubbables

import (
	"math/rand"
	"time"

	uuid "github.com/satori/go.uuid"
)

// Stubbables is a package of reusable functions that are
// exported as variables to make for easy stubbing

// TimeNow wraps time.Now
var TimeNow = time.Now

// UUIDv1 wraps uuid.NewV1().String
var UUIDv1 = func() string {
	return uuid.NewV1().String()
}

var chars = func() string {
	str := ""
	for c := '!'; c <= '~'; c++ {
		str += string(c)
	}
	return str
}()

var charsLen = len(chars)

// RandomStr returns a random string of length len
var RandomStr = func(len int) string {
	str := ""
	src := rand.New(rand.NewSource(TimeNow().UnixNano()))
	for i := 0; i < len; i++ {
		j := src.Intn(charsLen)
		str += string(chars[j])
	}
	return str
}
