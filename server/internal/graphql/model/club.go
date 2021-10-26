package model

type Club struct {
	Base
	Abbreviation   string     `json:"abbreviation"`
	Name           string     `json:"name"`
	PrimaryColor   string     `json:"primaryColor"`
	SecondaryColor string     `json:"secondaryColor"`
	AccentColor    string     `json:"accentColor"`
	Conference     Conference `json:"conference"`
	Active         bool       `json:"active"`
}
