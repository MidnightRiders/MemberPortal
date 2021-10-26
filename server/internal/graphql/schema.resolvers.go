package graphql

// This file will be automatically regenerated based on the schema, any resolver implementations
// will be copied through when generating and any unknown code will be moved to the end.

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/MidnightRiders/MemberPortal/server/internal/auth"
	"github.com/MidnightRiders/MemberPortal/server/internal/graphql/generated"
	"github.com/MidnightRiders/MemberPortal/server/internal/graphql/model"
	"github.com/MidnightRiders/MemberPortal/server/internal/users"
	"github.com/sirupsen/logrus"
)

func (r *mutationResolver) LogIn(ctx context.Context, username string, password string) (*model.Session, error) {
	sess, err := auth.LogIn(ctx, r.DB, auth.LogInPayload{Username: username, Password: password}, r.Env)
	if err != nil {
		return nil, err
	}
	return &model.Session{
		Token:   sess.ULID,
		Expires: sess.Expires.UTC(),
	}, nil
}

func (r *mutationResolver) LogOut(ctx context.Context) (bool, error) {
	result := auth.LogOut(ctx, r.DB, r.Env)
	if !result {
		return false, errors.New("an error was encountered while logging out")
	}
	return true, nil
}

func (r *mutationResolver) CreateUser(ctx context.Context, username string, email string, firstName string, lastName string, address1 string, address2 *string, city string, password string, province string, postalCode string, country string) (*model.User, error) {
	ulid, err := users.Create(ctx, r.DB, users.CreateProps{
		Username:   username,
		Password:   password,
		Email:      email,
		FirstName:  firstName,
		LastName:   lastName,
		Address1:   address1,
		Address2:   address2,
		City:       city,
		PostalCode: postalCode,
		Province:   province,
		Country:    country,
	})
	if err != nil {
		return nil, err
	}

	return r.Query().User(ctx, ulid)
}

func (r *mutationResolver) CreateRevGuess(ctx context.Context, userUlid string, matchUlid string, homeGoals int, awayGoals int, comment *string) (*model.RevGuess, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *mutationResolver) CreateManOfTheMatchVote(ctx context.Context, userUlid string, matchUlid string, firstPickUlid string, secondPickUlid *string, thirdPickUlid *string) (*model.ManOfTheMatchVote, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *mutationResolver) InitiatePasswordReset(ctx context.Context, email string) (*string, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *mutationResolver) ResetPassword(ctx context.Context, email string, password string, token string) (bool, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) User(ctx context.Context, ulid string) (*model.User, error) {
	var u *model.User
	if result := r.DB.WithContext(ctx).First(u, "ulid = ?", ulid); result.Error != nil {
		logrus.WithContext(ctx).WithError(result.Error).Error("error finding user")
		return nil, errors.New("could not find user")
	}

	return u, nil
}

func (r *queryResolver) Users(ctx context.Context) ([]*model.User, error) {
	var usrs []*model.User

	if result := r.DB.WithContext(ctx).Find(&usrs); result.Error != nil {
		return nil, result.Error
	}

	return usrs, nil
}

func (r *queryResolver) Membership(ctx context.Context, ulid *string, userUlid *string, year *int) (*model.Membership, error) {
	m := model.Membership{}
	query := r.DB.WithContext(ctx)
	if ulid != nil {
		query = query.Where("ulid = ?", *ulid)
	}
	if userUlid != nil {
		query = query.Where("user_ulid = ?", *userUlid)
	}
	if year != nil {
		query = query.Where("year = ?", *year)
	}

	if result := query.First(&m); result.Error != nil {
		return nil, result.Error
	}

	return &m, nil
}

func (r *queryResolver) Memberships(ctx context.Context, userUlid *string, year *int) ([]*model.Membership, error) {
	var memberships []*model.Membership

	query := r.DB.WithContext(ctx)
	if userUlid != nil {
		query = query.Where("user_ulid = ?", *userUlid)
	}
	if year != nil {
		query = query.Where("year = ?", *year)
	}

	if result := query.Find(&memberships); result.Error != nil {
		return nil, result.Error
	}

	return memberships, nil
}

func (r *queryResolver) Club(ctx context.Context, ulid string) (*model.Club, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) Clubs(ctx context.Context, conference *model.Conference) ([]*model.Club, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) Match(ctx context.Context, ulid string) (*model.Match, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) Matches(ctx context.Context, before *time.Time, after *time.Time, club *string) ([]*model.Match, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) RevGuess(ctx context.Context, userUlid string, matchUlid string) (*model.RevGuess, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) RevGuesses(ctx context.Context, matchUlid *string) ([]*model.RevGuess, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) ManOfTheMatchVote(ctx context.Context, userUlid string, matchUlid string) (*model.ManOfTheMatchVote, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) ManOfTheMatchVotes(ctx context.Context, matchUlid *string) ([]*model.ManOfTheMatchVote, error) {
	panic(fmt.Errorf("not implemented"))
}

// Mutation returns generated.MutationResolver implementation.
func (r *Resolver) Mutation() generated.MutationResolver { return &mutationResolver{r} }

// Query returns generated.QueryResolver implementation.
func (r *Resolver) Query() generated.QueryResolver { return &queryResolver{r} }

type mutationResolver struct{ *Resolver }
type queryResolver struct{ *Resolver }
