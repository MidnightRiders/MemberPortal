package auth

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"net/http"
	"os"
	"time"

	"golang.org/x/crypto/bcrypt"

	"github.com/MidnightRiders/MemberPortal/server/internal/cookie"
	"github.com/MidnightRiders/MemberPortal/server/internal/env"
	"github.com/MidnightRiders/MemberPortal/server/internal/memberships"
	"github.com/MidnightRiders/MemberPortal/server/internal/stubbables"
	"github.com/sirupsen/logrus"
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
		"SELECT u.uuid, u.password_digest, u.pepper, m.uuid as membership_uuid, a.uuid IS NOT NULL as is_admin "+
			"FROM users u "+
			"LEFT JOIN memberships m ON m.arrival_uuid = a.uuid "+
			fmt.Sprintf("AND m.year IN (%s) ", memberships.CurrentMembershipYears().ToString())+
			"LEFT JOIN admins a "+
			"ON a.user_uuid = u.uuid "+
			"WHERE u.username = ?",
		p.Username,
	)
	var userUUID, passwordDigest, pepper, membershipUUID string
	var isAdmin bool
	err := row.Scan(&userUUID, &passwordDigest, &pepper, &membershipUUID, &isAdmin)
	if err != nil {
		if err != sql.ErrNoRows {
			logrus.WithError(err).Error("Error looking up user for login")
		}
		return nil, errors.New("Invalid username or password")
	}

	salt := os.Getenv("PASSWORD_SALT")
	seasoned := []byte(p.Password + salt + pepper)
	err = bcrypt.CompareHashAndPassword([]byte(passwordDigest), seasoned)
	if err != nil {
		if err != bcrypt.ErrMismatchedHashAndPassword {
			logrus.WithError(err).Error("Error comparing hashed passwords")
		}
		return nil, errors.New("Invalid username or password")
	}

	expires := stubbables.TimeNow().Add(7 * 24 * time.Hour)

	sessionUUID := stubbables.UUIDv1()
	_, err = db.ExecContext(ctx, "INSERT INTO sessions VALUES (uuid = ?, user_uuid = ?, expires = ?)", sessionUUID, userUUID, expires)
	if err != nil {
		logrus.WithError(err).Error("Error creating session")
		return nil, errors.New("Unexpected error creating new session")
	}

	domain := ".midnightriders.com"
	if e == env.Dev {
		domain = "localhost"
	}

	cookie.Add(ctx, http.Cookie{
		Domain:   domain,
		Expires:  expires,
		Name:     "session",
		Path:     "/",
		SameSite: http.SameSiteStrictMode,
		Secure:   true,
		Value:    sessionUUID,
	})

	return &Session{
		Expires:  expires,
		IsAdmin:  isAdmin,
		UserUUID: userUUID,
		UUID:     sessionUUID,
	}, nil
}

// LogOut expires a cookie and removes the session from the database
func LogOut(ctx context.Context, db *sql.DB, e env.Env) bool {
	info := FromContext(ctx)
	if info == nil || !info.LoggedIn || info.UUID == "" {
		return false
	}

	lg := logrus.WithField("info", info)
	result, err := db.ExecContext(ctx, "DELETE FROM sessions WHERE uuid = ?", info.UUID)
	if err != nil {
		lg.WithError(err).Error("Error deleting session")
		return false
	}
	n, err := result.RowsAffected()
	if err != nil {
		lg.WithError(err).Error("Error getting rows affected from deleted session")
		return false
	}
	if n <= 0 {
		lg.Error("Rows affected when logging out was zero")
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
