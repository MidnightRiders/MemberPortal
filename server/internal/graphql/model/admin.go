package model

type Admin struct {
	Base
	UserULID string `gorm:"column:user_ulid;size:32"`
}
