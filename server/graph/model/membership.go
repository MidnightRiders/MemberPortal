package model

var MembershipColumns string = "uuid, user_uuid, year, type, role"

type Membership struct {
	UUID     string         `json:"uuid"`
	UserUUID string         `json:"user"`
	Year     int            `json:"year"`
	Type     MembershipType `json:"type"`
	Role     Role           `json:"role"`
}

func MembershipFromRow(row scannable) *Membership {
	m := &Membership{}
	row.Scan(
		m.UUID,
		m.UserUUID,
		m.Year,
		m.Type,
		m.Role,
	)
	if m.UUID == "" {
		return nil
	}
	return m
}
