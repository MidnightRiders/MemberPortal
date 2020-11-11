package env_test

import (
	"testing"

	"github.com/MidnightRiders/MemberPortal/server/internal/env"

	"github.com/stretchr/testify/assert"
)

func TestFromString(t *testing.T) {
	testCases := []struct {
		it string

		input string

		output env.Env
	}{
		{
			it: "converts staging",

			input: "staging",

			output: env.Staging,
		},
		{
			it: "converts Prod",

			input: "Prod",

			output: env.Prod,
		},
		{
			it: "converts dev",

			input: "Dev",

			output: env.Dev,
		},
		{
			it: "converts empty string to dev",

			input: "",

			output: env.Dev,
		},
		{
			it: "converts unknown string to dev",

			input: "flarg",

			output: env.Dev,
		},
	}

	t.Run("parallel group", func(g *testing.T) {
		for _, tc := range testCases {
			testCase := tc

			g.Run(testCase.it, func(test *testing.T) {
				test.Parallel()

				assert.Equal(test, testCase.output, env.FromString(testCase.input))
			})
		}
	})
}

func TestToString(t *testing.T) {
	testCases := []struct {
		it string

		input env.Env

		output string
	}{
		{
			it: "converts staging",

			input: env.Staging,

			output: "staging",
		},
		{
			it: "converts Prod",

			input: env.Prod,

			output: "prod",
		},
		{
			it: "converts dev",

			input: env.Dev,

			output: "dev",
		},
		{
			it: "converts an unknown int coerced to Env to Dev",

			input: env.Env(12),

			output: "dev",
		},
	}

	t.Run("parallel group", func(g *testing.T) {
		for _, tc := range testCases {
			testCase := tc

			g.Run(testCase.it, func(test *testing.T) {
				test.Parallel()

				assert.Equal(test, testCase.output, testCase.input.ToString())
			})
		}
	})
}
