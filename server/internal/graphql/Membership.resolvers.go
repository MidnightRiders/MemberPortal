package graphql

// This file will be automatically regenerated based on the schema, any resolver implementations
// will be copied through when generating and any unknown code will be moved to the end.

import (
	"context"
	"errors"

	"github.com/MidnightRiders/MemberPortal/server/internal/graphql/generated"
	"github.com/MidnightRiders/MemberPortal/server/internal/graphql/model"
)

func (r *membershipResolver) User(ctx context.Context, obj *model.Membership) (*model.User, error) {
	row := r.DB.QueryRowContext(ctx, "SELECT "+model.UserColumns+" FROM users WHERE uuid = ?", obj.UserUUID)
	user := model.UserFromRow(ctx, row)
	if user == nil {
		return nil, errors.New("Could not find user with UUID matching UserUUID of membership")
	}
	return user, nil
}

// Membership returns generated.MembershipResolver implementation.
func (r *Resolver) Membership() generated.MembershipResolver { return &membershipResolver{r} }

type membershipResolver struct{ *Resolver }
