package main

import (
	"database/sql"
	"log"
	"net/http"
	"os"

	"github.com/99designs/gqlgen/graphql/handler"
	"github.com/99designs/gqlgen/graphql/handler/extension"
	"github.com/99designs/gqlgen/graphql/playground"
	"github.com/golang-migrate/migrate/v4"
	"github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"

	"github.com/MidnightRiders/MemberPortal/server/graph"
	"github.com/MidnightRiders/MemberPortal/server/graph/generated"
	"github.com/MidnightRiders/MemberPortal/server/internal/auth"
	"github.com/MidnightRiders/MemberPortal/server/internal/env"
)

const defaultPort = "8080"

func main() {
	db, err := sql.Open("pgx", os.Getenv("DATABASE_URL"))
	if err != nil {
		log.Fatalf("Unable to connect to database: %v", err)
	}
	defer db.Close()

	driver, err := postgres.WithInstance(db, &postgres.Config{})
	if err != nil {
		log.Fatal(err)
	}

	m, err := migrate.NewWithDatabaseInstance(
		"file://migrations",
		"postgres",
		driver,
	)
	if err != nil {
		log.Fatal(err)
	}
	if err := m.Up(); err != nil && err != migrate.ErrNoChange {
		log.Fatal(err)
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = defaultPort
	}

	e := env.FromString(os.Getenv("APP_ENV"))
	log.Printf("Inferred environment is %s", e.ToString())
	domain := os.Getenv("DOMAIN")

	cfg := generated.Config{
		Resolvers: &graph.Resolver{
			DB:     db,
			Domain: domain,
			Env:    e,
		},
	}

	srv := handler.NewDefaultServer(generated.NewExecutableSchema(cfg))
	srv.Use(extension.FixedComplexityLimit(5))

	if e != env.Prod {
		http.Handle("/playground", playground.Handler("GraphQL playground", "/"))
		log.Printf("connect to http://localhost:%s/playground for GraphQL playground", port)
	}
	authMiddleware := auth.CreateMiddleware(db, domain)
	http.Handle("/", authMiddleware(srv))

	log.Fatal(http.ListenAndServe(":"+port, nil))
}
