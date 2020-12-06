package main

import (
	"context"
	"database/sql"
	"net/http"
	"os"

	"github.com/99designs/gqlgen/graphql"
	"github.com/99designs/gqlgen/graphql/handler"
	"github.com/99designs/gqlgen/graphql/playground"
	"github.com/golang-migrate/migrate/v4"
	"github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	_ "github.com/jackc/pgx/v4/stdlib"
	"github.com/sirupsen/logrus"

	"github.com/MidnightRiders/MemberPortal/server/graph"
	"github.com/MidnightRiders/MemberPortal/server/graph/generated"
	"github.com/MidnightRiders/MemberPortal/server/internal/auth"
	"github.com/MidnightRiders/MemberPortal/server/internal/env"
)

const defaultPort = "8080"

func init() {
	logrus.SetLevel(logrus.DebugLevel)
	logrus.SetOutput(os.Stdout)
}

func main() {
	db, err := sql.Open("pgx", os.Getenv("DATABASE_URL"))
	if err != nil {
		logrus.WithError(err).Fatalf("Unable to connect to database: %v", err)
	}
	defer db.Close()

	driver, err := postgres.WithInstance(db, &postgres.Config{})
	if err != nil {
		logrus.WithError(err).Fatal("Error initializing Postgres driver")
	}

	m, err := migrate.NewWithDatabaseInstance(
		"file://migrations",
		"postgres",
		driver,
	)
	if err != nil {
		logrus.WithError(err).Error("Error initializing migrations")
	}
	if err := m.Up(); err != nil && err != migrate.ErrNoChange {
		logrus.WithError(err).Error("Error executing migrations")
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = defaultPort
	}

	e := env.FromString(os.Getenv("APP_ENV"))
	logrus.Debugf("Inferred environment is %s", e.ToString())
	domain := os.Getenv("DOMAIN")

	cfg := generated.Config{
		Resolvers: &graph.Resolver{
			DB:     db,
			Domain: domain,
			Env:    e,
		},
	}

	srv := handler.NewDefaultServer(generated.NewExecutableSchema(cfg))
	// srv.Use(extension.FixedComplexityLimit(5))
	srv.AroundOperations(func(ctx context.Context, next graphql.OperationHandler) graphql.ResponseHandler {
		if !auth.FromContext(ctx).IsAdmin {
			graphql.GetOperationContext(ctx).DisableIntrospection = true
		}

		return next(ctx)
	})

	authMiddleware := auth.CreateMiddleware(db, domain)
	http.Handle("/", authMiddleware(srv))

	if e != env.Prod {
		http.Handle("/playground", playground.Handler("GraphQL playground", "/"))
		logrus.Infof("connect to http://localhost:%s/playground for GraphQL playground", port)
	}

	logrus.Infof("Listening on http://localhost:%s", port)
	if err = http.ListenAndServe(":"+port, nil); err != nil {
		logrus.WithError(err).Fatal("Error calling ListenAndServe")
	}
}
