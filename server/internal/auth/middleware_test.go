package auth_test

import (
	"database/sql"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/MidnightRiders/MemberPortal/server/internal/auth"
	"github.com/MidnightRiders/MemberPortal/server/internal/memberships"
	"github.com/MidnightRiders/MemberPortal/server/internal/testhelpers"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/stretchr/testify/assert"
)

func TestCreateMiddleware(t *testing.T) {
	testCases := []struct {
		it string

		req       *http.Request
		prepareDB func() (*sql.DB, func(*testing.T), error)

		proxiedAssertions  func(*testing.T) http.HandlerFunc
		responseAssertions func(*testing.T, *httptest.ResponseRecorder)
	}{
		{
			it: "adds empty Info to context when no cookie is set",

			req: testhelpers.BuildReq(testhelpers.ReqParams{}),

			proxiedAssertions: func(test *testing.T) http.HandlerFunc {
				return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
					assert.Equal(test, auth.Info{}, *auth.FromContext(r.Context()))
					w.WriteHeader(http.StatusOK)
				})
			},
			responseAssertions: func(test *testing.T, w *httptest.ResponseRecorder) {
				assert.Equal(test, len(w.Result().Cookies()), 0)
				assert.Equal(test, http.StatusOK, w.Code)
			},
		},
		{
			it: "adds empty Info to context and invalidates when invalid cookie is set",

			req: testhelpers.BuildReq(testhelpers.ReqParams{
				Cookies: []*http.Cookie{
					{
						Name:  "session",
						Value: "awpeuripewurpawoeiru",
					},
				},
			}),

			proxiedAssertions: func(test *testing.T) http.HandlerFunc {
				return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
					assert.Equal(test, auth.Info{}, *auth.FromContext(r.Context()))
					w.WriteHeader(http.StatusOK)
				})
			},
			responseAssertions: func(test *testing.T, w *httptest.ResponseRecorder) {
				cookies := w.Result().Cookies()

				assert.Equal(test, len(cookies), 1)

				testhelpers.AssertEqualCookie(test, http.Cookie{
					Name:     "session",
					Domain:   "midnightriders.com",
					Value:    "",
					Expires:  auth.ExpireTime,
					SameSite: http.SameSiteStrictMode,
					Secure:   true,
				}, cookies[0])
				assert.Equal(test, http.StatusOK, w.Code)
			},
		},
		{
			it: "adds empty Info to context and invalidates when expired cookie is set",

			prepareDB: func() (*sql.DB, func(*testing.T), error) {
				db, mock, err := sqlmock.New()
				if err != nil {
					return db, func(*testing.T) {}, err
				}

				mock.ExpectQuery(
					"SELECT s.uuid, s.user_uuid, s.expires, m.uuid IS NOT NULL as current_member.*\\(2020\\)",
				).WithArgs(
					"2bd02a90-2384-11eb-9dc9-7bccc7b63366",
				).WillReturnRows(sqlmock.NewRows([]string{"uuid", "user_uuid", "expires", "current_member"}).AddRow(
					"2bd02a90-2384-11eb-9dc9-7bccc7b63366",
					"c13b3760-2388-11eb-bf34-89ffdb72692c",
					auth.ExpireTime,
					false,
				))
				mock.ExpectExec("DELETE FROM sessions").WithArgs("2bd02a90-2384-11eb-9dc9-7bccc7b63366")

				dbCalled := func(test *testing.T) {
					err := mock.ExpectationsWereMet()
					assert.NoError(test, err)
				}

				return db, dbCalled, nil
			},
			req: testhelpers.BuildReq(testhelpers.ReqParams{
				Cookies: []*http.Cookie{
					{
						Name:  "session",
						Value: "2bd02a90-2384-11eb-9dc9-7bccc7b63366",
					},
				},
			}),

			proxiedAssertions: func(test *testing.T) http.HandlerFunc {
				return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
					assert.Equal(test, auth.Info{}, *auth.FromContext(r.Context()))
					w.WriteHeader(http.StatusOK)
				})
			},
			responseAssertions: func(test *testing.T, w *httptest.ResponseRecorder) {
				cookies := w.Result().Cookies()

				assert.Equal(test, len(cookies), 1)

				testhelpers.AssertEqualCookie(test, http.Cookie{
					Name:     "session",
					Domain:   "midnightriders.com",
					Value:    "",
					Expires:  auth.ExpireTime,
					SameSite: http.SameSiteStrictMode,
					Secure:   true,
				}, cookies[0])
				assert.Equal(test, http.StatusOK, w.Code)
			},
		},
		{
			it: "adds populated Info to context and updates expiration when valid cookie is set",

			prepareDB: func() (*sql.DB, func(*testing.T), error) {
				db, mock, err := sqlmock.New()
				if err != nil {
					return db, func(*testing.T) {}, err
				}

				mock.ExpectQuery(
					"SELECT s.uuid, s.user_uuid, s.expires, m.uuid IS NOT NULL as current_member.*\\(2020\\)",
				).WithArgs(
					"2bd02a90-2384-11eb-9dc9-7bccc7b63366",
				).WillReturnRows(sqlmock.NewRows([]string{"uuid", "user_uuid", "expires", "current_member"}).AddRow(
					"2bd02a90-2384-11eb-9dc9-7bccc7b63366",
					"c13b3760-2388-11eb-bf34-89ffdb72692c",
					time.Date(2020, 7, 30, 12, 0, 0, 0, time.UTC),
					true,
				))
				mock.ExpectExec("UPDATE sessions").WithArgs(
					time.Date(2020, 7, 30, 20, 29, 0, 0, time.UTC),
					"2bd02a90-2384-11eb-9dc9-7bccc7b63366",
				)

				dbCalled := func(test *testing.T) {
					err := mock.ExpectationsWereMet()
					assert.NoError(test, err)
				}

				return db, dbCalled, nil
			},
			req: testhelpers.BuildReq(testhelpers.ReqParams{
				Cookies: []*http.Cookie{
					{
						Name:  "session",
						Value: "2bd02a90-2384-11eb-9dc9-7bccc7b63366",
					},
				},
			}),

			proxiedAssertions: func(test *testing.T) http.HandlerFunc {
				exp := time.Date(2020, 7, 30, 20, 29, 0, 0, time.UTC)
				return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
					assert.Equal(test, auth.Info{
						CurrentMember: true,
						Expires:       &exp,
						LoggedIn:      true,
						UUID:          "c13b3760-2388-11eb-bf34-89ffdb72692c",
					}, *auth.FromContext(r.Context()))
					w.WriteHeader(http.StatusOK)
				})
			},
			responseAssertions: func(test *testing.T, w *httptest.ResponseRecorder) {
				cookies := w.Result().Cookies()

				assert.Equal(test, len(cookies), 1)

				testhelpers.AssertEqualCookie(test, http.Cookie{
					Name:     "session",
					Domain:   "midnightriders.com",
					Value:    "2bd02a90-2384-11eb-9dc9-7bccc7b63366",
					Expires:  time.Date(2020, 7, 30, 20, 29, 0, 0, time.UTC),
					SameSite: http.SameSiteStrictMode,
					Secure:   true,
				}, cookies[0])
				assert.Equal(test, http.StatusOK, w.Code)
			},
		},
	}

	atn := auth.TimeNow
	mtn := memberships.TimeNow
	auth.TimeNow = func() time.Time {
		return time.Date(2020, 7, 29, 20, 29, 0, 0, time.UTC)
	}
	memberships.TimeNow = func() time.Time {
		return time.Date(2020, 7, 29, 20, 29, 0, 0, time.UTC)
	}
	defer func() {
		auth.TimeNow = atn
	}()
	defer func() {
		memberships.TimeNow = mtn
	}()

	t.Run("parallel group", func(g *testing.T) {
		for _, tc := range testCases {
			testCase := tc

			g.Run(testCase.it, func(test *testing.T) {
				test.Parallel()

				var db *sql.DB
				mockExpectation := func(*testing.T) {}
				var err error
				if testCase.prepareDB == nil {
					db, _, err = sqlmock.New()
				} else {
					db, mockExpectation, err = testCase.prepareDB()
				}
				if err != nil {
					test.Fatal(err)
				}
				defer db.Close()
				middleware := auth.CreateMiddleware(db, ".midnightriders.com")
				w := httptest.NewRecorder()

				var inner http.HandlerFunc
				if testCase.proxiedAssertions == nil {
					inner = http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
						w.WriteHeader(http.StatusOK)
					})
				} else {
					inner = testCase.proxiedAssertions(test)
				}

				middleware(inner).ServeHTTP(w, testCase.req)

				// Wait for goroutine
				time.Sleep(50 * time.Millisecond)

				mockExpectation(test)
				testCase.responseAssertions(test, w)
			})
		}
	})
}
