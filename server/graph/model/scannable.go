package model

type scannable interface {
	Scan(...interface{}) error
}
