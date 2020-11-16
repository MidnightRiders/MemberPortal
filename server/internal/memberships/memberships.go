package memberships

import "github.com/MidnightRiders/MemberPortal/server/internal/stubbables"

func isEndOfSeason() bool {
	return stubbables.TimeNow().Month() > 10
}

// CurrentMembershipYears returns the year(s) for which a
// member might be considered a "current" member
func CurrentMembershipYears() []int {
	if isEndOfSeason() {
		return []int{stubbables.TimeNow().Year(), stubbables.TimeNow().Year() + 1}
	}
	return []int{stubbables.TimeNow().Year()}
}

// NewMembershipYear returns the year for which new
// memberships should be created
func NewMembershipYear() int {
	if isEndOfSeason() {
		return stubbables.TimeNow().Year() + 1
	}
	return stubbables.TimeNow().Year()
}
