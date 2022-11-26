package utils_test

import (
	"strconv"
	"testing"

	"github.com/MidnightRiders/MemberPortal/server/internal/utils"
	"github.com/stretchr/testify/assert"
)

type MapTestCase[T any, V any] struct {
	it string

	cb func(t T, i int) V

	in  []T
	out []V
}

func TestMap(t *testing.T) {
	testCases := []MapTestCase[int, string]{
		{
			it: "maps an array of ints to an array of strings",

			cb: func(t int, _ int) string {
				return strconv.Itoa(t)
			},

			in:  []int{1, 2, 3, 4, 5},
			out: []string{"1", "2", "3", "4", "5"},
		},
	}

	t.Run("parallel group", func(g *testing.T) {
		for _, tc := range testCases {
			testCase := tc
			g.Run(testCase.it, func(test *testing.T) {
				test.Parallel()

				result := utils.Map(testCase.in, testCase.cb)

				assert.Equal(test, testCase.out, result)
			})
		}
	})
}
