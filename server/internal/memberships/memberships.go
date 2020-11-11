package memberships

import "time"

// TimeNow wraps time.Now for testing
var TimeNow = time.Now

func isEndOfSeason() bool {
	return TimeNow().Month() > 10
}

// CurrentMembershipYears returns the year(s) for which a
// member might be considered a "current" member
func CurrentMembershipYears() []int {
	if isEndOfSeason() {
		return []int{TimeNow().Year(), TimeNow().Year() + 1}
	}
	return []int{TimeNow().Year()}
}

// NewMembershipYear returns the year for which new
// memberships should be created
func NewMembershipYear() int {
	if isEndOfSeason() {
		return TimeNow().Year() + 1
	}
	return TimeNow().Year()
}
