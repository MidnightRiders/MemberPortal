package main

import (
	"context"
	"net/http"
	"os"

	gql "github.com/99designs/gqlgen/graphql"
	"github.com/99designs/gqlgen/graphql/handler"
	"github.com/99designs/gqlgen/graphql/handler/extension"
	"github.com/99designs/gqlgen/graphql/playground"
	_ "github.com/jackc/pgx/v4/stdlib"
	"github.com/sirupsen/logrus"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"

	"github.com/MidnightRiders/MemberPortal/server/internal/auth"
	"github.com/MidnightRiders/MemberPortal/server/internal/env"
	"github.com/MidnightRiders/MemberPortal/server/internal/graphql"
	"github.com/MidnightRiders/MemberPortal/server/internal/graphql/generated"
	"github.com/MidnightRiders/MemberPortal/server/internal/graphql/model"
)

const defaultPort = "8080"

func init() { //nolint:gochecknoinits
	logrus.SetLevel(logrus.DebugLevel)
	logrus.SetOutput(os.Stdout)
	logrus.SetFormatter(&logrus.JSONFormatter{})
}

func main() {
	db, err := gorm.Open(postgres.Open(os.Getenv("DATABASE_URL")), &gorm.Config{})
	if err != nil {
		logrus.WithError(err).Fatal("Unable to connect to database")
	}
	if err := db.AutoMigrate(
		&model.User{},
		&model.Admin{},
		&model.Club{},
		&model.Player{},
		&model.ManOfTheMatchVote{},
		&model.RevGuess{},
		&model.Membership{},
		&model.Session{},
	); err != nil {
		logrus.WithError(err).Fatal("Unable to AutoMigrate")
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = defaultPort
	}

	e := env.FromString(os.Getenv("APP_ENV"))
	logrus.Debugf("Inferred environment is %s", e.ToString())
	domain := os.Getenv("DOMAIN")

	cfg := generated.Config{
		Resolvers: &graphql.Resolver{
			DB:     db,
			Domain: domain,
			Env:    e,
		},
	}

	srv := handler.NewDefaultServer(generated.NewExecutableSchema(cfg))
	// srv.Use(extension.FixedComplexityLimit(5))
	srv.AroundOperations(func(ctx context.Context, next gql.OperationHandler) gql.ResponseHandler {
		if !auth.FromContext(ctx).IsAdmin {
			gql.GetOperationContext(ctx).DisableIntrospection = true
		}

		return next(ctx)
	})

	if e != env.Prod {
		srv.Use(extension.Introspection{})
		http.Handle("/playground", playground.Handler("GraphQL playground", "/"))
		logrus.Infof("connect to http://localhost:%s/playground for GraphQL playground", port)
	}

	authMiddleware := auth.CreateMiddleware(db, domain)
	http.Handle("/", authMiddleware(srv))

	logrus.Infof("Listening on http://localhost:%s", port)
	if err = http.ListenAndServe(":"+port, nil); err != nil {
		logrus.WithError(err).Fatal("Error calling ListenAndServe")
	}
}
