// Package env just provides enums for the environment
package env

import "strings"

// Env describes the current environment
type Env int

// Env is considered to be Dev unless otherwise specified
const (
	Dev Env = iota
	Staging
	Prod
)

// FromString provides an Env enum from a string
func FromString(e string) Env {
	switch strings.ToLower(e) {
	case "staging":
		return Staging
	case "prod":
		return Prod
	default:
		return Dev
	}
}

// ToString provides a human-readable string from the Env enum
func (e Env) ToString() string {
	switch e {
	case Staging:
		return "staging"
	case Prod:
		return "prod"
	default:
		return "dev"
	}
}
