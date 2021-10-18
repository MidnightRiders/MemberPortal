package auth

import (
	"context"
	"errors"
	"net/http"
	"os"
	"time"

	"github.com/sirupsen/logrus"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"

	"github.com/MidnightRiders/MemberPortal/server/internal/cookie"
	"github.com/MidnightRiders/MemberPortal/server/internal/env"
	"github.com/MidnightRiders/MemberPortal/server/internal/graphql/model"
	"github.com/MidnightRiders/MemberPortal/server/internal/memberships"
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
func LogIn(ctx context.Context, db *gorm.DB, p LogInPayload, e env.Env) (*Session, error) {
	u := model.User{}
	if result := db.WithContext(ctx).Joins(
		"Membership", db.Where("year in ?", memberships.CurrentMembershipYears()),
	).First(
		&u, "username = ?", p.Username,
	); result.Error != nil {
		logrus.WithContext(ctx).WithError(result.Error).Warn("could not find user for LogIn")
		return nil, errors.New("invalid username or password")
	}
	isAdmin := len(u.Memberships) > 0
	//row := pg.QueryRowContext(
	//	ctx,
	//	"SELECT u.ulid, u.password_digest, u.pepper, m.ulid as membership_ulid, a.ulid IS NOT NULL as is_admin "+
	//		"FROM users u "+
	//		"LEFT JOIN memberships m ON m.arrival_ulid = a.ulid "+
	//		fmt.Sprintf("AND m.year IN (%s) ", memberships.CurrentMembershipYears().ToString())+
	//		"LEFT JOIN admins a "+
	//		"ON a.user_ulid = u.ulid "+
	//		"WHERE u.username = ?",
	//	p.Username,
	//)
	//var userULID, passwordDigest, pepper, membershipULID string
	//err := row.Scan(&userULID, &passwordDigest, &pepper, &membershipULID, &isAdmin)
	//if err != nil {
	//	if err != sql.ErrNoRows {
	//		logrus.WithError(err).Error("Error looking up user for login")
	//	}
	//	return nil, errors.New("Invalid username or password")
	//}

	salt := os.Getenv("PASSWORD_SALT")
	seasoned := []byte(p.Password + salt + u.Pepper)
	err := bcrypt.CompareHashAndPassword([]byte(u.PasswordDigest), seasoned)
	if err != nil {
		if err != bcrypt.ErrMismatchedHashAndPassword {
			logrus.WithError(err).Error("Error comparing hashed passwords")
		}
		return nil, errors.New("Invalid username or password")
	}

	expires := stubbables.TimeNow().Add(7 * 24 * time.Hour)

	s := model.Session{UserULID: u.ULID, Expires: expires, IsAdmin: isAdmin}
	if result := db.Create(&s); result.Error != nil {
		logrus.WithError(result.Error).Error("error creating session")
		return nil, errors.New("unexpected error creating new session")
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
		Value:    s.ULID,
	})

	return &Session{
		Expires:  expires,
		IsAdmin:  isAdmin,
		UserULID: u.ULID,
		ULID:     s.ULID,
	}, nil
}

// LogOut expires a cookie and removes the session from the database
func LogOut(ctx context.Context, db *gorm.DB, e env.Env) bool {
	info := FromContext(ctx)
	if info == nil || !info.LoggedIn || info.ULID == "" {
		return false
	}

	lg := logrus.WithField("info", info)
	result := db.Delete(&model.Session{Base: model.Base{ULID: info.ULID}})
	if result.Error != nil {
		lg.WithError(result.Error).Error("error deleting session")
		return false
	}
	if result.RowsAffected == 1 {
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
