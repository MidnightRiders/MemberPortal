package graph

// This file will be automatically regenerated based on the schema, any resolver implementations
// will be copied through when generating and any unknown code will be moved to the end.

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/MidnightRiders/MemberPortal/server/graph/generated"
	"github.com/MidnightRiders/MemberPortal/server/graph/model"
	"github.com/MidnightRiders/MemberPortal/server/internal/auth"
	"github.com/MidnightRiders/MemberPortal/server/internal/users"
)

func (r *membershipResolver) User(ctx context.Context, obj *model.Membership) (*model.User, error) {
	row := r.DB.QueryRowContext(ctx, "SELECT "+model.UserColumns+" FROM users WHERE uuid = ?", obj.UserUUID)
	user := model.UserFromRow(row)
	if user == nil {
		return nil, errors.New("Could not find user with UUID matching UserUUID of membership")
	}
	return user, nil
}

func (r *mutationResolver) LogIn(ctx context.Context, username string, password string) (*model.Session, error) {
	sess, err := auth.LogIn(ctx, r.DB, auth.LogInPayload{Username: username, Password: password}, r.Env)
	if err != nil {
		return nil, err
	}
	return &model.Session{
		Token:   sess.UUID,
		Expires: sess.Expires.UTC(),
	}, nil
}

func (r *mutationResolver) LogOut(ctx context.Context) (bool, error) {
	result := auth.LogOut(ctx, r.DB, r.Env)
	if result == false {
		return false, errors.New("An error was encountered while logging out")
	}
	return true, nil
}

func (r *mutationResolver) CreateUser(ctx context.Context, username string, email string, firstName string, lastName string, address1 string, address2 *string, city string, password string, province string, postalCode string, country string) (*model.User, error) {
	uuid, err := users.Create(ctx, r.DB, users.CreateProps{
		Username:  username,
		Password:  password,
		Email:     email,
		FirstName: firstName,
		LastName:  lastName,
		Address1:  address1,
		Address2:  address2,
		City:      city,
		Province:  province,
		Country:   country,
	})
	if err != nil {
		return nil, err
	}

	return r.Query().User(ctx, uuid)
}

func (r *mutationResolver) CreateRevGuess(ctx context.Context, userUUID string, matchUUID string, homeGoals int, awayGoals int, comment *string) (*model.RevGuess, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *mutationResolver) CreateManOfTheMatchVote(ctx context.Context, userUUID string, matchUUID string, firstPickUUID string, secondPickUUID *string, thirdPickUUID *string) (*model.ManOfTheMatchVote, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) User(ctx context.Context, uuid string) (*model.User, error) {
	row := r.DB.QueryRowContext(ctx, "SELECT "+model.UserColumns+" FROM users WHERE uuid = ? LIMIT 1", uuid)
	if row == nil {
		return nil, nil
	}

	return model.UserFromRow(row), nil
}

func (r *queryResolver) Users(ctx context.Context) ([]*model.User, error) {
	users := []*model.User{}

	resp, err := r.DB.QueryContext(ctx, "SELECT "+model.UserColumns+" FROM users")
	if err != nil {
		return users, err
	}
	defer resp.Close()

	for resp.Next() {
		if user := model.UserFromRow(resp); user != nil {
			users = append(users, user)
		}
	}
	return users, nil
}

func (r *queryResolver) Membership(ctx context.Context, uuid *string, userUUID *string, year *int) (*model.Membership, error) {
	query := "SELECT " + model.MembershipColumns + " FROM memberships"
	conditions := []string{}
	args := []interface{}{}

	if uuid != nil {
		conditions = append(conditions, "uuid = ?")
		args = append(args, *uuid)
	}
	if userUUID != nil {
		conditions = append(conditions, "user_uuid = ?")
		args = append(args, *userUUID)
	}
	if year != nil {
		conditions = append(conditions, "year = ?")
		args = append(args, *year)
	}
	if len(conditions) > 0 {
		query += " WHERE " + strings.Join(conditions, " AND ")
	}

	row := r.DB.QueryRowContext(ctx, query, args...)

	return model.MembershipFromRow(row), nil
}

func (r *queryResolver) Memberships(ctx context.Context, userUUID *string, year *int) ([]*model.Membership, error) {
	memberships := []*model.Membership{}

	query := "SELECT " + model.MembershipColumns + " FROM memberships"
	conditions := []string{}
	args := []interface{}{}
	if userUUID != nil {
		conditions = append(conditions, "user_uuid = ?")
		args = append(args, *userUUID)
	}
	if year != nil {
		conditions = append(conditions, "year = ?")
		args = append(args, *year)
	}
	if len(conditions) > 0 {
		query += " WHERE " + strings.Join(conditions, " AND ")
	}

	resp, err := r.DB.QueryContext(ctx, query, args...)
	if err != nil {
		return memberships, err
	}

	for resp.Next() {
		if membership := model.MembershipFromRow(resp); membership != nil {
			memberships = append(memberships, membership)
		}
	}
	return memberships, nil
}

func (r *queryResolver) Club(ctx context.Context, uuid string) (*model.Club, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) Clubs(ctx context.Context, conference *model.Conference) ([]*model.Club, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) Match(ctx context.Context, uuid string) (*model.Match, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) Matches(ctx context.Context, before *time.Time, after *time.Time, club *string) ([]*model.Match, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) RevGuess(ctx context.Context, userUUID string, matchUUID string) (*model.RevGuess, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) RevGuesses(ctx context.Context, matchID *string) ([]*model.RevGuess, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) ManOfTheMatchVote(ctx context.Context, userUUID string, matchUUID string) (*model.ManOfTheMatchVote, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) ManOfTheMatchVotes(ctx context.Context, matchID *string) ([]*model.ManOfTheMatchVote, error) {
	panic(fmt.Errorf("not implemented"))
}

// Membership returns generated.MembershipResolver implementation.
func (r *Resolver) Membership() generated.MembershipResolver { return &membershipResolver{r} }

// Mutation returns generated.MutationResolver implementation.
func (r *Resolver) Mutation() generated.MutationResolver { return &mutationResolver{r} }

// Query returns generated.QueryResolver implementation.
func (r *Resolver) Query() generated.QueryResolver { return &queryResolver{r} }

type membershipResolver struct{ *Resolver }
type mutationResolver struct{ *Resolver }
type queryResolver struct{ *Resolver }
