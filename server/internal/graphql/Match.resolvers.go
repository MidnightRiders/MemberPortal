package graphql

// This file will be automatically regenerated based on the schema, any resolver implementations
// will be copied through when generating and any unknown code will be moved to the end.

import (
	"context"
	"fmt"

	"github.com/MidnightRiders/MemberPortal/server/internal/graphql/generated"
	"github.com/MidnightRiders/MemberPortal/server/internal/graphql/model"
)

func (r *matchResolver) Kickoff(ctx context.Context, obj *model.Match) (string, error) {
	panic(fmt.Errorf("not implemented"))
}

// Match returns generated.MatchResolver implementation.
func (r *Resolver) Match() generated.MatchResolver { return &matchResolver{r} }

type matchResolver struct{ *Resolver }
