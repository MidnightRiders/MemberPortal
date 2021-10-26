package model

type Player struct {
	Base
	FirstName string   `json:"firstName"`
	LastName  string   `json:"lastName"`
	Position  Position `json:"position"`
	ClubULID  string   `json:"-" gorm:"column:club_ulid"`
	Active    bool     `json:"active"`

	Club *Club `json:"club"`
}
