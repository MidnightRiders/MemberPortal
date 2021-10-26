package model

type RevGuess struct {
	Base
	MatchULID string  `json:"-" gorm:"column:match_ulid"`
	UserULID  string  `json:"-" gorm:"column:user_ulid"`
	HomeGoals int     `json:"homeGoals"`
	AwayGoals int     `json:"awayGoals"`
	Comment   *string `json:"comment"`

	Match *Match `json:"match"`
	User  *User  `json:"user"`
}
