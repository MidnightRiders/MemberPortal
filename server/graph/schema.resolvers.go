package graph

// This file will be automatically regenerated based on the schema, any resolver implementations
// will be copied through when generating and any unknown code will be moved to the end.

import (
	"context"
	"fmt"

	"github.com/MidnightRiders/MemberPortal/server/graph/generated"
	"github.com/MidnightRiders/MemberPortal/server/graph/model"
	"github.com/MidnightRiders/MemberPortal/server/internal/db"
)

func (r *mutationResolver) CreateUser(ctx context.Context, email string, firstName string, lastName string, address1 string, address2 *string, city string, password string, province *string, postalCode string, country string) (*model.User, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *mutationResolver) CreateRevGuess(ctx context.Context, useruuid string, matchuuid string, homeGoals int, awayGoals int, comment *string) (*model.RevGuess, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *mutationResolver) CreateManOfTheMatchVote(ctx context.Context, useruuid string, matchuuid string, firstPickuuid string, secondPickID *string, thirdPickID *string) (*model.ManOfTheMatchVote, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) User(ctx context.Context, uuid string) (*model.User, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) Users(ctx context.Context) ([]*model.User, error) {
	users := []*model.User{}
	db, err := db.FromContext(ctx)
	if err != nil {
		return users, err
	}

	resp, err := db.Query("SELECT uuid, email, first_name, last_name, address1, address2, city, province, postal_code, country FROM USERS;")
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

func (r *queryResolver) Membership(ctx context.Context, useruuid string, year int) (*model.Membership, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) Memberships(ctx context.Context, userID *string, year *int) ([]*model.Membership, error) {
	panic(fmt.Errorf("not implemented"))
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

func (r *queryResolver) RevGuess(ctx context.Context, useruuid string, matchuuid string) (*model.RevGuess, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) RevGuesses(ctx context.Context, matchID *string) ([]*model.RevGuess, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) ManOfTheMatchVote(ctx context.Context, useruuid string, matchuuid string) (*model.ManOfTheMatchVote, error) {
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
