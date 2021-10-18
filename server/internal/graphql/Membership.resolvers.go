package graphql

// This file will be automatically regenerated based on the schema, any resolver implementations
// will be copied through when generating and any unknown code will be moved to the end.

import (
	"context"
	"errors"

	"github.com/sirupsen/logrus"

	"github.com/MidnightRiders/MemberPortal/server/internal/graphql/generated"
	"github.com/MidnightRiders/MemberPortal/server/internal/graphql/model"
)

func (r *membershipResolver) User(ctx context.Context, obj *model.Membership) (*model.User, error) {
	var user *model.User
	if result := r.DB.First(user, "ulid = ?", obj.UserULID); result.Error != nil {
		logrus.WithContext(ctx).WithError(result.Error).Error("error getting user")
		return nil, errors.New("could not find user with ULID matching UserULID of membership")
	}
	return user, nil
}

// Membership returns generated.MembershipResolver implementation.
func (r *Resolver) Membership() generated.MembershipResolver { return &membershipResolver{r} }

type membershipResolver struct{ *Resolver }
