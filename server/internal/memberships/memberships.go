package memberships

import (
	"strconv"
	"strings"

	"github.com/MidnightRiders/MemberPortal/server/internal/stubbables"
)

func isEndOfSeason() bool {
	return stubbables.TimeNow().Month() > 10
}

// MembershipYears is a list of years that can have added functionality
type MembershipYears []int

// CurrentMembershipYears returns the year(s) for which a
// member might be considered a "current" member
func CurrentMembershipYears() MembershipYears {
	if isEndOfSeason() {
		return MembershipYears{stubbables.TimeNow().Year(), stubbables.TimeNow().Year() + 1}
	}
	return MembershipYears{stubbables.TimeNow().Year()}
}

// ToString converts the list of years, which are ints, to strings
func (yrs MembershipYears) ToString() string {
	y := []string{}
	for _, yr := range yrs {
		y = append(y, strconv.Itoa(yr))
	}
	return strings.Join(y, ", ")
}

// NewMembershipYear returns the year for which new
// memberships should be created
func NewMembershipYear() int {
	if isEndOfSeason() {
		return stubbables.TimeNow().Year() + 1
	}
	return stubbables.TimeNow().Year()
}
