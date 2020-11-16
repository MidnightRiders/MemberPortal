package auth

import (
	"context"
	"database/sql"
	"errors"
	"log"
	"net/http"
	"os"
	"time"

	"golang.org/x/crypto/bcrypt"

	"github.com/MidnightRiders/MemberPortal/server/internal/cookie"
	"github.com/MidnightRiders/MemberPortal/server/internal/env"
	"github.com/MidnightRiders/MemberPortal/server/internal/stubbables"
)

// Level describes the level of authentication
type Level int

// Enum for levels of authentication
const (
	Unauthed Level = iota
	LoggedIn
	Admin
)

// LogInPayload is what the LogIn function expects from the user
type LogInPayload struct {
	Username string
	Password string
}

// LogIn performs login from a GraphQL request
func LogIn(ctx context.Context, db *sql.DB, p LogInPayload, e env.Env) (*Session, error) {
	row := db.QueryRowContext(
		ctx,
		"SELECT u.uuid, u.password_digest, u.pepper, m.uuid as membership_uuid FROM users u WHERE u.username = ?",
		p.Username,
	)
	var userUUID, passwordDigest, pepper, membershipUUID string
	err := row.Scan(&userUUID, &passwordDigest, &pepper, &membershipUUID)
	if err != nil {
		if err != sql.ErrNoRows {
			log.Printf("Error looking up user for login: %v", err)
		}
		return nil, errors.New("Invalid username or password")
	}

	salt := os.Getenv("PASSWORD_SALT")
	seasoned := []byte(p.Password + salt + pepper)
	err = bcrypt.CompareHashAndPassword([]byte(passwordDigest), seasoned)
	if err != nil {
		if err != bcrypt.ErrMismatchedHashAndPassword {
			log.Printf("Error comparing hashed passwords: %v", err)
		}
		return nil, errors.New("Invalid username or password")
	}

	expires := stubbables.TimeNow().Add(7 * 24 * time.Hour)

	sessionUUID := stubbables.UUIDv1()
	_, err = db.ExecContext(ctx, "INSERT INTO sessions VALUES (uuid = ?, user_uuid = ?, expires = ?)", sessionUUID, userUUID, expires)
	if err != nil {
		log.Printf("Error creating session: %v", err)
		return nil, errors.New("Unexpected error creating new session")
	}

	info := Info{
		UUID:          userUUID,
		Expires:       &expires,
		LoggedIn:      true,
		CurrentMember: membershipUUID != "",
	}

	domain := ".midnightriders.com"
	if e == env.Dev {
		domain = "localhost"
	}

	cookie.Add(AddToContext(ctx, info), http.Cookie{
		Domain:   domain,
		Expires:  expires,
		Name:     "session",
		Path:     "/",
		SameSite: http.SameSiteStrictMode,
		Secure:   true,
		Value:    sessionUUID,
	})

	return &Session{
		UUID:     sessionUUID,
		UserUUID: userUUID,
		Expires:  expires,
	}, nil
}

// LogOut expires a cookie and removes the session from the database
func LogOut(ctx context.Context, db *sql.DB, e env.Env) bool {
	info := FromContext(ctx)
	if info == nil || !info.LoggedIn || info.UUID == "" {
		return false
	}

	result, err := db.ExecContext(ctx, "DELETE FROM sessions WHERE uuid = ?", info.UUID)
	if err != nil {
		log.Printf("Error deleting session: %v", err)
		return false
	}
	n, err := result.RowsAffected()
	if err != nil {
		log.Printf("Error getting rows affected from deleted session: %v", err)
		return false
	}
	if n <= 0 {
		log.Println("Rows affected when logging out was zero")
		return false
	}

	domain := ".midnightriders.com"
	if e == env.Dev {
		domain = "localhost"
	}

	cookie.Add(ctx, http.Cookie{
		Domain:   domain,
		Expires:  ExpireTime,
		Name:     "session",
		Path:     "/",
		SameSite: http.SameSiteStrictMode,
		Secure:   true,
		Value:    "",
	})

	return true
}
