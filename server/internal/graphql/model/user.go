package model

type User struct {
	Base
	Username         string  `json:"username"`
	Email            string  `json:"email"`
	FirstName        string  `json:"firstName"`
	LastName         string  `json:"lastName"`
	Address1         string  `json:"address1"`
	Address2         *string `json:"address2"`
	City             string  `json:"city"`
	Province         *string `json:"province"`
	PostalCode       string  `json:"postalCode"`
	Country          string  `json:"country"`
	Admin            bool    `json:"admin"`
	MembershipNumber int     `json:"membershipNumber"`

	Memberships []*Membership `json:"-"`

	PasswordDigest string `json:"-" gorm:"column:password_digest"`
	Pepper         string `json:"-" gorm:"column:pepper"`

	Admins []*Admin `json:"-" gorm:"foreignKey:user_ulid;references:"`
}
