package model

type Membership struct {
	Base
	UserULID string         `json:"userULID" gorm:"column:user_ulid"`
	Year     int            `json:"year"`
	Type     MembershipType `json:"type"`
	Role     Role           `json:"role"`
}
