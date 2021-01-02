package auth

// Action is an enum to describe the actions that Can
// may be passed
type Action int

// Action enums
const (
	ActionUnknown Action = iota
)

// Can says whether the current auth context can do a thing
func (i *Info) Can(action Action) bool {
	if action == ActionUnknown {
		return true
	}

	return false
}
