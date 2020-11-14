package auth

import (
	"database/sql"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/MidnightRiders/MemberPortal/server/internal/memberships"
)

type Session struct {
	UUID     string
	UserUUID string
	Expires  time.Time
}

// ExpireTime is a reusable time for expiring cookies
var ExpireTime time.Time = time.Date(1995, 12, 1, 12, 0, 0, 0, time.UTC)

// TimeNow wraps time.Now so it can be stubbed for testing
var TimeNow func() time.Time = time.Now

func setCookie(w http.ResponseWriter, domain string, uuid string, expires time.Time) {
	http.SetCookie(w, &http.Cookie{
		Name:     "session",
		Domain:   domain,
		Path:     "/",
		Value:    uuid,
		Expires:  expires,
		SameSite: http.SameSiteStrictMode,
		Secure:   true,
	})
}

var userWithCurrentMembershipQuery = strings.Trim(`
SELECT s.uuid, s.user_uuid, s.expires, m.uuid IS NOT NULL as current_member
FROM sessions s
	LEFT JOIN memberships m ON m.user_uuid = s.user_uuid AND m.year IN (%s)
WHERE s.uuid = ?
ORDER BY m.year DESC
GROUP BY s.user_uuid
`, " \n")

func strYrs() []string {
	a := []string{}
	for _, yr := range memberships.CurrentMembershipYears() {
		a = append(a, strconv.Itoa(yr))
	}
	return a
}

// CreateMiddleware returns a Middleware function for authenticating
// requests
func CreateMiddleware(db *sql.DB, domain string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			ctx := r.Context()
			authCookie, err := r.Cookie("session")
			sessionInfo := Info{}
			if err == nil && authCookie.Value != "" {
				sessionUUID := authCookie.Value
				row := db.QueryRowContext(ctx, fmt.Sprintf(userWithCurrentMembershipQuery, strings.Join(strYrs(), ",")), sessionUUID)
				sess := Session{}
				currentMember := false
				err := row.Scan(
					&sess.UUID,
					&sess.UserUUID,
					&sess.Expires,
					&currentMember,
				)
				if err == nil && sess.Expires.After(TimeNow()) && sess.UserUUID != "" {
					expires := TimeNow().Add(24 * time.Hour)
					go func(db *sql.DB) {
						db.Exec("UPDATE sessions SET expires = ? WHERE uuid = ?", expires, sessionUUID)
					}(db)
					sessionInfo.CurrentMember = currentMember
					sessionInfo.Expires = &expires
					sessionInfo.LoggedIn = true
					sessionInfo.UUID = sess.UserUUID
					setCookie(w, domain, sess.UUID, expires)
				} else {
					go func(db *sql.DB) {
						db.Exec("DELETE FROM sessions WHERE uuid = ?", sessionUUID)
					}(db)
					setCookie(w, domain, "", ExpireTime)
				}
			}
			next.ServeHTTP(w, r.WithContext(AddToContext(ctx, sessionInfo)))
		})
	}
}
