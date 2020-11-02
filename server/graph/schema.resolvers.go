package graph

// This file will be automatically regenerated based on the schema, any resolver implementations
// will be copied through when generating and any unknown code will be moved to the end.

import (
	"context"
	"fmt"

	"github.com/MidnightRiders/MemberPortal/server/graph/generated"
	"github.com/MidnightRiders/MemberPortal/server/graph/model"
)

func (r *mutationResolver) CreateUser(ctx context.Context, email string, firstName string, lastName string, address1 string, address2 *string, city string, state *string, postalCode string, country string) (*model.User, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *mutationResolver) CreateRevGuess(ctx context.Context, userID string, matchID string, homeGoals int, awayGoals int, comment *string) (*model.RevGuess, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *mutationResolver) CreateManOfTheMatchVote(ctx context.Context, userID string, matchID string, firstPickID string, secondPickID *string, thirdPickID *string) (*model.ManOfTheMatchVote, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) User(ctx context.Context, id string) (*model.User, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) Users(ctx context.Context) ([]*model.User, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) Membership(ctx context.Context, userID string, year int) (*model.Membership, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) Memberships(ctx context.Context, userID *string, year *int) ([]*model.Membership, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) Club(ctx context.Context, id string) (*model.Club, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) Clubs(ctx context.Context, conference *model.Conference) ([]*model.Club, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) Match(ctx context.Context, id string) (*model.Match, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) Matches(ctx context.Context, before *string, after *string, club *string) ([]*model.Match, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) RevGuess(ctx context.Context, userID string, matchID string) (*model.RevGuess, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) RevGuesses(ctx context.Context, matchID *string) ([]*model.RevGuess, error) {
	panic(fmt.Errorf("not implemented"))
}

func (r *queryResolver) ManOfTheMatchVote(ctx context.Context, userID string, matchID string) (*model.ManOfTheMatchVote, error) {
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
