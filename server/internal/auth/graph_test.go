package auth_test

import (
	"context"
	"database/sql"
	"errors"
	"net/http"
	"testing"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/stretchr/testify/assert"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"

	"github.com/MidnightRiders/MemberPortal/server/internal/auth"
	"github.com/MidnightRiders/MemberPortal/server/internal/cookie"
	"github.com/MidnightRiders/MemberPortal/server/internal/env"
	"github.com/MidnightRiders/MemberPortal/server/internal/testhelpers"
)

func createLogInSetup(ctx context.Context, prepareDB func(sqlmock.Sqlmock), p auth.LogInPayload) logInSetup {
	db, mock, err := sqlmock.New()
	if err != nil {
		panic(err)
	}
	gdb, err := gorm.Open(postgres.New(postgres.Config{Conn: db}))
	if err != nil {
		panic(err)
	}
	expectMock := func() error { return nil }
	if prepareDB != nil {
		prepareDB(mock)
		expectMock = mock.ExpectationsWereMet
	}
	var cookies []http.Cookie

	return logInSetup{
		ctx: cookie.AddToContext(ctx, &cookies),
		db:  gdb,
		p:   p,
		e:   env.Prod,

		cookies:    &cookies,
		expectMock: expectMock,
	}
}

type logInSetup struct {
	ctx context.Context
	db  *gorm.DB
	p   auth.LogInPayload
	e   env.Env

	cookies    *[]http.Cookie
	expectMock func() error
}

const fakePepper = "fake-pepper"

func TestLogIn(t *testing.T) {
	now := time.Date(2020, 7, 29, 8, 29, 0, 0, time.Local)
	tdtime := testhelpers.StubTimeNow(&now)
	defer tdtime()
	salt := "stubbed-password-salt"
	tdsalt := testhelpers.StubEnvVar("PASSWORD_SALT", salt)
	defer tdsalt()

	expires := time.Date(2020, 8, 5, 8, 29, 0, 0, time.Local)
	stubbedULID := "xxxx-xxxx-xxxxx-xxxx"

	testCases := []struct {
		it    string
		setup logInSetup

		want        *auth.Session
		wantCookies []http.Cookie
		wantErr     string
	}{
		{
			it: "returns nil and error if no user found",

			setup: createLogInSetup(context.Background(), func(mock sqlmock.Sqlmock) {
				mock.ExpectQuery(`SELECT "users"`).WithArgs([]int{2020}, "foo").WillReturnError(sql.ErrNoRows)
			}, auth.LogInPayload{Username: "foo", Password: "bar"}),

			want:    nil,
			wantErr: "invalid username or password",
		},
		{
			it: "returns nil and error if password does not match",

			setup: createLogInSetup(context.Background(), func(mock sqlmock.Sqlmock) {
				rows := sqlmock.NewRows([]string{"ulid", "password_digest", "pepper", "membership_ulid", "is_admin"})
				pepper := fakePepper
				hashed, err := bcrypt.GenerateFromPassword([]byte("bad-password"+salt+pepper), bcrypt.DefaultCost)
				if err != nil {
					panic(err)
				}
				rows.AddRow(
					"360cfc56-ef91-4458-811c-897eab8f7b3c", string(hashed), pepper, "041aaf72-40a9-4f32-8539-d5c4ee591f0d", false,
				)
				mock.ExpectQuery(`SELECT "users"\.`).WithArgs([]int{2020}, "foo").WillReturnRows(rows)
			}, auth.LogInPayload{Username: "foo", Password: "wrong-password"}),

			want:    nil,
			wantErr: "invalid username or password",
		},
		{
			it: "returns nil and error if new session cannot be created",

			setup: createLogInSetup(context.Background(), func(mock sqlmock.Sqlmock) {
				rows := sqlmock.NewRows([]string{"ulid", "password_digest", "pepper", "membership_ulid", "is_admin"})
				pepper := fakePepper
				hashed, err := bcrypt.GenerateFromPassword([]byte("bad-password"+salt+pepper), bcrypt.DefaultCost)
				if err != nil {
					panic(err)
				}
				rows.AddRow(
					"360cfc56-ef91-4458-811c-897eab8f7b3c", string(hashed), pepper, "041aaf72-40a9-4f32-8539-d5c4ee591f0d", false,
				)
				mock.ExpectQuery(`SELECT "users"\.`).WithArgs([]int{2020}, "foo").WillReturnRows(rows)
				mock.ExpectExec("INSERT INTO sessions").WithArgs(
					sqlmock.AnyArg(),
					"360cfc56-ef91-4458-811c-897eab8f7b3c",
					time.Date(2020, 8, 5, 8, 29, 0, 0, time.Local),
				).WillReturnError(errors.New("couldn't create session"))
				mock.ExpectRollback()
			}, auth.LogInPayload{Username: "foo", Password: "bad-password"}),

			want:    nil,
			wantErr: "unexpected error creating new session",
		},
		{
			it: "returns Session and adds cookie to context if successful",

			setup: createLogInSetup(context.Background(), func(mock sqlmock.Sqlmock) {
				rows := sqlmock.NewRows([]string{"ulid", "password_digest", "pepper", "membership_ulid", "is_admin"})
				pepper := fakePepper
				hashed, err := bcrypt.GenerateFromPassword([]byte("bad-password"+salt+pepper), bcrypt.DefaultCost)
				if err != nil {
					panic(err)
				}
				rows.AddRow(
					"360cfc56-ef91-4458-811c-897eab8f7b3c", string(hashed), pepper, "041aaf72-40a9-4f32-8539-d5c4ee591f0d", false,
				)
				mock.ExpectQuery(`SELECT "users"\.`).WithArgs([]int{2020}, "foo").WillReturnRows(rows)
				mock.ExpectExec("INSERT INTO sessions").WithArgs(
					sqlmock.AnyArg(),
					"360cfc56-ef91-4458-811c-897eab8f7b3c",
					expires,
				).WillReturnResult(sqlmock.NewResult(0, 1))
				mock.ExpectCommit()
			}, auth.LogInPayload{Username: "foo", Password: "bad-password"}),

			want: &auth.Session{
				ULID:     stubbedULID,
				Expires:  expires,
				UserULID: "360cfc56-ef91-4458-811c-897eab8f7b3c",
			},
			wantCookies: []http.Cookie{
				{
					Domain:   ".midnightriders.com",
					Expires:  expires,
					Name:     "session",
					Path:     "/",
					SameSite: http.SameSiteStrictMode,
					Secure:   true,
					Value:    "match-ulid",
				},
			},
			wantErr: "",
		},
		{
			it: "returns Session with admin and adds cookie to context if successful",

			setup: createLogInSetup(context.Background(), func(mock sqlmock.Sqlmock) {
				rows := sqlmock.NewRows([]string{"ulid", "password_digest", "pepper", "membership_ulid", "is_admin"})
				pepper := fakePepper
				hashed, err := bcrypt.GenerateFromPassword([]byte("bad-password"+salt+pepper), bcrypt.DefaultCost)
				if err != nil {
					panic(err)
				}
				rows.AddRow(
					"360cfc56-ef91-4458-811c-897eab8f7b3c", string(hashed), pepper, "041aaf72-40a9-4f32-8539-d5c4ee591f0d", true,
				)
				mock.ExpectQuery(`SELECT "users"\.`).WithArgs([]int{2020}, "foo").WillReturnRows(rows)
				mock.ExpectExec("INSERT INTO sessions").WithArgs(
					sqlmock.AnyArg(),
					"360cfc56-ef91-4458-811c-897eab8f7b3c",
					expires,
				).WillReturnResult(sqlmock.NewResult(0, 1))
				mock.ExpectCommit()
			}, auth.LogInPayload{Username: "foo", Password: "bad-password"}),

			want: &auth.Session{
				Expires:  expires,
				IsAdmin:  true,
				UserULID: "360cfc56-ef91-4458-811c-897eab8f7b3c",
				ULID:     stubbedULID,
			},
			wantCookies: []http.Cookie{
				{
					Domain:   ".midnightriders.com",
					Expires:  expires,
					Name:     "session",
					Path:     "/",
					SameSite: http.SameSiteStrictMode,
					Secure:   true,
					Value:    "match-ulid",
				},
			},
			wantErr: "",
		},
	}

	t.Run("parallel group", func(g *testing.T) {
		for _, tc := range testCases {
			testCase := tc

			g.Run(testCase.it, func(test *testing.T) {
				test.Parallel()

				got, err := auth.LogIn(testCase.setup.ctx, testCase.setup.db, testCase.setup.p, testCase.setup.e)

				if got != nil {
					got.ULID = stubbedULID
				}

				assert.NoError(test, testCase.setup.expectMock())
				var gotCookies []*http.Cookie
				for _, ck := range *testCase.setup.cookies {
					c := ck
					gotCookies = append(gotCookies, &c)
				}
				testhelpers.AssertEqualCookies(test, testCase.wantCookies, gotCookies)
				if testCase.wantErr == "" {
					assert.NoError(test, err)
				} else {
					assert.EqualError(test, err, testCase.wantErr)
				}
				assert.Equal(test, testCase.want, got)
			})
		}
	})
}

type logOutSetup struct {
	ctx context.Context
	db  *gorm.DB
	e   env.Env

	cookies    *[]http.Cookie
	expectMock func() error
}

func createLogOutSetup(ctx context.Context, prepareDB func(mock sqlmock.Sqlmock)) logOutSetup {
	db, mock, err := sqlmock.New()
	if err != nil {
		panic(err)
	}
	if prepareDB != nil {
		prepareDB(mock)
	}
	gdb, err := gorm.Open(postgres.New(postgres.Config{Conn: db}), &gorm.Config{})
	if err != nil {
		panic(err)
	}
	var cookies []http.Cookie

	return logOutSetup{
		ctx: cookie.AddToContext(ctx, &cookies),
		db:  gdb,
		e:   env.Prod,

		cookies:    &cookies,
		expectMock: mock.ExpectationsWereMet,
	}
}

func TestLogOut(t *testing.T) {
	testCases := []struct {
		it    string
		setup logOutSetup

		want        bool
		wantCookies []http.Cookie
	}{
		{
			it: "returns false if no auth in context",

			setup: createLogOutSetup(context.Background(), nil),

			want: false,
		},
		{
			it: "returns false if session can't be deleted",

			setup: createLogOutSetup(
				auth.AddToContext(context.Background(), auth.Info{
					LoggedIn: true,
					ULID:     "cb75830f-a5a4-4440-8079-097da4500e95",
				}),
				func(mock sqlmock.Sqlmock) {
					mock.ExpectExec("DELETE FROM sessions").WithArgs(
						"cb75830f-a5a4-4440-8079-097da4500e95",
					).WillReturnError(errors.New("nope!"))
				}),

			want: false,
		},
		{
			it: "returns false if no rows affected",

			setup: createLogOutSetup(
				auth.AddToContext(context.Background(), auth.Info{
					LoggedIn: true,
					ULID:     "cb75830f-a5a4-4440-8079-097da4500e95",
				}),
				func(mock sqlmock.Sqlmock) {
					mock.ExpectExec("DELETE FROM sessions").WithArgs(
						"cb75830f-a5a4-4440-8079-097da4500e95",
					).WillReturnResult(sqlmock.NewResult(1, 0))
				}),

			want: false,
		},
		{
			it: "expires cookie and returns true if everything checks out",

			setup: createLogOutSetup(
				auth.AddToContext(context.Background(), auth.Info{
					LoggedIn: true,
					ULID:     "cb75830f-a5a4-4440-8079-097da4500e95",
				}),
				func(mock sqlmock.Sqlmock) {
					mock.ExpectExec("DELETE FROM sessions").WithArgs(
						"cb75830f-a5a4-4440-8079-097da4500e95",
					).WillReturnResult(sqlmock.NewResult(1, 1))
				}),

			want: true,
			wantCookies: []http.Cookie{
				{
					Domain:   ".midnightriders.com",
					Expires:  auth.ExpireTime,
					Name:     "session",
					Path:     "/",
					SameSite: http.SameSiteStrictMode,
					Secure:   true,
					Value:    "",
				},
			},
		},
	}

	t.Run("parallel group", func(g *testing.T) {
		for _, tc := range testCases {
			testCase := tc

			g.Run(testCase.it, func(test *testing.T) {
				test.Parallel()

				got := auth.LogOut(testCase.setup.ctx, testCase.setup.db, testCase.setup.e)

				assert.NoError(test, testCase.setup.expectMock())
				var gotCookies []*http.Cookie
				for _, c := range *testCase.setup.cookies {
					ck := c
					gotCookies = append(gotCookies, &ck)
				}
				testhelpers.AssertEqualCookies(test, testCase.wantCookies, gotCookies)
				assert.Equal(test, testCase.want, got)
			})
		}
	})
}
