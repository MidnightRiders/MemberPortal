package auth

import (
	"net/http"
	"strconv"
	"time"

	"gorm.io/gorm"

	"github.com/MidnightRiders/MemberPortal/server/internal/graphql/model"
	"github.com/MidnightRiders/MemberPortal/server/internal/memberships"
	"github.com/MidnightRiders/MemberPortal/server/internal/stubbables"
)

// Session describes the current user's session
type Session struct {
	Expires  time.Time
	IsAdmin  bool
	UserULID string
	ULID     string
}

// ExpireTime is a reusable time for expiring cookies
var ExpireTime time.Time = time.Date(1995, 12, 1, 12, 0, 0, 0, time.UTC)

func setCookie(w http.ResponseWriter, domain string, ulid string, expires time.Time) {
	http.SetCookie(w, &http.Cookie{
		Name:     "session",
		Domain:   domain,
		Path:     "/",
		Value:    ulid,
		Expires:  expires,
		SameSite: http.SameSiteStrictMode,
		Secure:   true,
	})
}

func strYrs() []string {
	a := []string{}
	for _, yr := range memberships.CurrentMembershipYears() {
		a = append(a, strconv.Itoa(yr))
	}
	return a
}

const dayHours = 24 * time.Hour

// CreateMiddleware returns a Middleware function for authenticating
// requests
func CreateMiddleware(db *gorm.DB, domain string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			ctx := r.Context()
			authCookie, err := r.Cookie("session")
			sessionInfo := Info{}
			if err == nil && authCookie.Value != "" {
				sessionULID := authCookie.Value
				sess := model.Session{}
				result := db.WithContext(ctx).Preload(
					"User",
				).Preload(
					"User.Memberships", db.Where("year IN ?", strYrs()),
				).First(&sess, "ulid = ?", sessionULID)
				err := result.Error
				currentMember := false
				if err == nil && sess.Expires.After(stubbables.TimeNow()) && sess.UserULID != "" {
					currentMember = len(sess.User.Memberships) > 0
					expires := stubbables.TimeNow().Add(dayHours)
					go func(db *gorm.DB) {
						db.Model(&model.Session{}).Where("ulid = ?", sessionULID).Update("expires = ?", expires)
					}(db)
					sessionInfo.CurrentMember = currentMember
					sessionInfo.Expires = &expires
					sessionInfo.LoggedIn = true
					sessionInfo.ULID = sess.UserULID
					setCookie(w, domain, sess.ULID, expires)
				} else {
					go func(db *gorm.DB) {
						db.WithContext(ctx).Delete(&model.Session{}, sessionULID)
					}(db)
					setCookie(w, domain, "", ExpireTime)
				}
			}
			next.ServeHTTP(w, r.WithContext(AddToContext(ctx, sessionInfo)))
		})
	}
}
