package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"io/ioutil"
	"log"
	"os"
	"strings"

	_ "github.com/jackc/pgx/v4/stdlib"

	"github.com/MidnightRiders/MemberPortal/server/internal/ulid"
)

func main() {
	dir := ""
	if len(os.Args) > 1 {
		dir = os.Args[1]
	}
	if dir == "" {
		log.Fatal("Must specify import directory")
	}
	s, err := os.Stat(dir)
	if os.IsNotExist(err) {
		log.Fatalf(`Directory "%s" does not exist`, dir)
	}
	if !s.IsDir() {
		log.Fatalf(`Path "%s" is not a directory`, dir)
	}

	oldTables := map[string][]map[string]interface{}{
		"users":       {},
		"clubs":       {},
		"matches":     {},
		"memberships": {},
		"mot_ms":      {},
		"pick_ems":    {},
		"rev_guesses": {},
	}
	for table := range oldTables {
		if _, err = os.Stat(dir + "/" + table + ".json"); os.IsNotExist(err) {
			log.Fatalf(`Directory %s is missing %s.json`, dir, table)
		}
		f, err := os.Open(dir + "/" + table + ".json") //nolint:gosec // this is a safe string reference
		if err != nil {
			log.Fatalf(`Could not open %s/%s.json: %v`, dir, table, err)
		}
		defer f.Close()
		body, _ := ioutil.ReadAll(f)
		var val []map[string]interface{}
		if err := json.Unmarshal(body, &val); err != nil {
			log.Fatalf(`Could not unmarshal JSON from %s/%s.json: %v`, dir, table, err)
		}
		oldTables[table] = val
	}

	db, err := sql.Open("pgx", os.Getenv("DATABASE_URL"))
	if err != nil {
		log.Fatalf("Could not create database connection: %v", err)
	}
	defer db.Close()

	tx, err := db.BeginTx(context.Background(), &sql.TxOptions{})
	if err != nil {
		log.Fatalf("Could not begin transaction: %v", err)
	}
	defer tx.Rollback()

	query := `
		INSERT INTO
			users (username, first_name, last_name, email, address1, city, province, postal_code, country, membership_number, ulid)
			VALUES ( $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11 )
	`
	stmt, err := tx.Prepare(query)
	if err != nil {
		log.Fatalf("Error preparing Users query: %v", err)
	}
	defer stmt.Close()
	generator := ulid.NewGenerator()
	for _, user := range oldTables["users"] {
		args := make([]interface{}, 11)
		for i, field := range []string{"username", "first_name", "last_name", "email", "address", "province", "postal_code", "country"} {
			v, ok := user[field].(string)
			if ok {
				args[i] = strings.Trim(v, " \n\t")
			} else {
				args[i] = nil
			}
		}
		args[9] = int(user["id"].(float64))
		args[10] = generator.String()
		if _, err := stmt.Exec(args...); err != nil {
			log.Fatalf("Error inserting user %s: %v", user["username"], err)
		}
	}

	if err := tx.Commit(); err != nil {
		log.Fatalf("Error committing transaction: %v", err)
	}

	log.Print("Import complete.")
}
