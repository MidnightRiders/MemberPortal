package memberships

import (
	"strconv"
	"strings"

	"github.com/MidnightRiders/MemberPortal/server/internal/stubbables"
	"github.com/MidnightRiders/MemberPortal/server/internal/utils"
)

// October is the last month of the regular season, so it's the last month
// when new memberships apply to the current year
const endOfSeasonMonth = 10

func isEndOfSeason() bool {
	return stubbables.TimeNow().Month() > endOfSeasonMonth
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
	return strings.Join(utils.Map(yrs, func(yr int, _ int) string {
		return strconv.Itoa(yr)
	}), ", ")
}

// NewMembershipYear returns the year for which new
// memberships should be created
func NewMembershipYear() int {
	if isEndOfSeason() {
		return stubbables.TimeNow().Year() + 1
	}
	return stubbables.TimeNow().Year()
}
