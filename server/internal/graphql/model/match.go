package model

import (
	"time"
)

type Match struct {
	Base
	Kickoff      time.Time   `json:"kickoff"`
	HomeClubULID string      `json:"-" gorm:"column:home_club_ulid"`
	AwayClubULID string      `json:"-" gorm:"column:away_club_ulid"`
	HomeClub     *Club       `json:"homeClub"`
	AwayClub     *Club       `json:"awayClub"`
	HomeGoals    *int        `json:"homeGoals"`
	AwayGoals    *int        `json:"awayGoals"`
	Status       MatchStatus `json:"status"`

	RevGuesses         []*RevGuess          `json:"revGuesses"`
	ManOfTheMatchVotes []*ManOfTheMatchVote `json:"manOfTheMatchVotes"`
}
