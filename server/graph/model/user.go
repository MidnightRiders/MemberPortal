package model

var UserColumns string = "uuid, email, first_name, last_name, address1, address2, city, province, postal_code, country"

type User struct {
	UUID             string        `json:"uuid"`
	Username         string        `json:"username"`
	Email            string        `json:"email"`
	FirstName        string        `json:"firstName"`
	LastName         string        `json:"lastName"`
	Address1         string        `json:"address1"`
	Address2         *string       `json:"address2"`
	City             string        `json:"city"`
	Province         *string       `json:"province"`
	PostalCode       string        `json:"postalCode"`
	Country          string        `json:"country"`
	Admin            bool          `json:"admin"`
	MembershipNumber int           `json:"membershipNumber"`
	Memberships      []*Membership `json:"memberships"`
}

func UserFromRow(row scannable) *User {
	user := &User{}
	row.Scan(
		user.UUID,
		user.Email,
		user.FirstName,
		user.LastName,
		// TODO: this is only visible to admins and board members
		user.Address1,
		user.Address2,
		user.City,
		user.Province,
		user.PostalCode,
		user.Country,
	)
	if user.UUID == "" {
		return nil
	}
	return user
}
