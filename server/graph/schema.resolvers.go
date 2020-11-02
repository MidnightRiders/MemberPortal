package graph

// This file will be automatically regenerated based on the schema, any resolver implementations
// will be copied through when generating and any unknown code will be moved to the end.

import (
	"context"
	"fmt"
	"strings"

	"github.com/MidnightRiders/MemberPortal/server/graph/generated"
	"github.com/MidnightRiders/MemberPortal/server/graph/model"
	"github.com/MidnightRiders/MemberPortal/server/internal/db"
)

func (r *mutationResolver) CreateUser(ctx context.Context, username string, email string, firstName string, lastName string, address1 string, address2 *string, city string, password string, province *string, postalCode string, country string) (*model.User, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *mutationResolver) CreateRevGuess(ctx context.Context, userUUID string, matchUUID string, homeGoals int, awayGoals int, comment *string) (*model.RevGuess, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *mutationResolver) CreateManOfTheMatchVote(ctx context.Context, userUUID string, matchUUID string, firstPickUUID string, secondPickUUID *string, thirdPickUUID *string) (*model.ManOfTheMatchVote, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) User(ctx context.Context, uuid string) (*model.User, error) {
	db, err := db.FromContext(ctx)
	if err != nil {
		return nil, err
	}

	row := db.QueryRowContext(ctx, "SELECT "+userColumns+" FROM users WHERE uuid = ? LIMIT 1", uuid)
	if row == nil {
		return nil, nil
	}

	user := &model.User{}
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
		return nil, nil
	}

	return user, nil
}

func (r *queryResolver) Users(ctx context.Context) ([]*model.User, error) {
	users := []*model.User{}
	db, err := db.FromContext(ctx)
	if err != nil {
		return users, err
	}

	resp, err := db.QueryContext(ctx, "SELECT "+userColumns+" FROM users")
	if err != nil {
		return users, err
	}
	defer resp.Close()

	for resp.Next() {
		user := &model.User{}
		resp.Scan(
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
		users = append(users, user)
	}
	return users, nil
}

func (r *queryResolver) Membership(ctx context.Context, uuid *string, userUUID *string, year *int) (*model.Membership, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) Memberships(ctx context.Context, userUUID *string, year *int) ([]*model.Membership, error) {
	memberships := []*model.Membership{}

	db, err := db.FromContext(ctx)
	if err != nil {
		return memberships, err
	}

	query := "SELECT " + membershipColumns + " FROM memberships"
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
	query += " " + strings.Join(conditions, " AND ")

	resp, err := db.QueryContext(ctx, query, args...)
	if err != nil {
		return memberships, err
	}

	for resp.Next() {
		membership := &model.Membership{}
		resp.Scan(
			membership.UUID,
		)
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

func (r *queryResolver) Matches(ctx context.Context, before *string, after *string, club *string) ([]*model.Match, error) {
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

// Mutation returns generated.MutationResolver implementation.
func (r *Resolver) Mutation() generated.MutationResolver { return &mutationResolver{r} }

// Query returns generated.QueryResolver implementation.
func (r *Resolver) Query() generated.QueryResolver { return &queryResolver{r} }

type mutationResolver struct{ *Resolver }
type queryResolver struct{ *Resolver }
