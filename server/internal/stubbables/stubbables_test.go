package stubbables_test

import (
	"fmt"
	"testing"

	"github.com/MidnightRiders/MemberPortal/server/internal/stubbables"
	"github.com/stretchr/testify/assert"
)

func TestRandomStr(t *testing.T) {
	testCases := []int{20, 64, 120}

	t.Run("parallel group", func(g *testing.T) {
		for _, tc := range testCases {
			testCase := tc

			g.Run(fmt.Sprintf("%d characters", testCase), func(test *testing.T) {
				test.Parallel()

				str := stubbables.RandomStr(testCase)

				assert.Len(test, str, testCase)
				for i := 0; i < testCase; i++ {
					assert.GreaterOrEqual(test, string(str[i]), "!")
					assert.LessOrEqual(test, string(str[i]), "~")
				}
			})
		}
	})
}
