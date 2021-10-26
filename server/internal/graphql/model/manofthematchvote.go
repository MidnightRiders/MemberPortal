package model

type ManOfTheMatchVote struct {
	Base
	MatchULID      string `json:"-" gorm:"column:match_ulid"`
	UserULID       string `json:"-" gorm:"column:user_ulid"`
	FirstPickULID  string `json:"-" gorm:"column:first_pick_ulid"`
	SecondPickULID string `json:"-" gorm:"column:second_pick_ulid"`
	ThirdPickULID  string `json:"-" gorm:"column:third_pick_ulid"`

	Match      *Match  `json:"match"`
	User       *User   `json:"user"`
	FirstPick  *Player `json:"firstPick"`
	SecondPick *Player `json:"secondPick"`
	ThirdPick  *Player `json:"thirdPick"`
}
