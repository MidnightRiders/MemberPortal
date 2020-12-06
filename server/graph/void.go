package graph

import "io"

// Void is a custom scalar that's just null
type Void struct{}

// UnmarshalGQL unmarshals Void to nil
func (v *Void) UnmarshalGQL(i interface{}) error {
	v = nil
	return nil
}

// MarshalGQL marshals Void to GraphQL
func (v Void) MarshalGQL(w io.Writer) {
	w.Write([]byte("null"))
}
