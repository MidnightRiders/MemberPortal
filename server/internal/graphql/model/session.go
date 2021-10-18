package model

import (
	"time"
)

type Session struct {
	Base
	UserULID string    `gorm:"column:user_ulid;size:32"`
	Expires  time.Time `json:"expires"`
	IsAdmin  bool      `json:"isAdmin"`
	Token    string    `json:"token"`
	User     User      `json:""`
}
