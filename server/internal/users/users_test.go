package users_test

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/stretchr/testify/assert"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"

	"github.com/MidnightRiders/MemberPortal/server/internal/testhelpers"
	"github.com/MidnightRiders/MemberPortal/server/internal/users"
)

func TestPasswordIsValid(t *testing.T) {
	testCases := []struct {
		it string

		password string

		want bool
	}{
		{
			it: "rejects a password that is too short",

			password: "Asdf1",

			want: false,
		},
		{
			it: "rejects a password that is too long",

			password: "@xdT9dPcoRmeXk7yoDeNPhTf@@ozW.qd49_UJf28wXu*iVC3QXBH-HcgqZ8Naweuro",

			want: false,
		},
		{
			it: "rejects a password that has no letters",

			password: "1287429874174012470!!!&&",

			want: false,
		},
		{
			it: "rejects a password that has no non-letters",

			password: "AweourpowurouoeruWER",

			want: false,
		},
		{
			it: "rejects a password that has characters that are not letters or non-letters",

			password: "Malin Åkerman",

			want: false,
		},
		{
			it: "accepts a valid password",

			password: "correct horse battery staple",

			want: true,
		},
		{
			it: "accepts a valid password",

			password: "t7gFRW8WZk6E",

			want: true,
		},
		{
			it: "accepts a valid password",

			password: "@xdT9dPcoRmeXk7yoDeNPhTf@@ozW.qd49_UJf28wXu*iVC3QXBH-HcgqZ8N",

			want: true,
		},
	}

	t.Run("parallel group", func(g *testing.T) {
		for _, tc := range testCases {
			testCase := tc

			g.Run(testCase.it, func(test *testing.T) {
				test.Parallel()

				got := users.PasswordIsValid(testCase.password)

				assert.Equal(test, got, testCase.want)
			})
		}
	})
}

type setup struct {
	ctx   context.Context
	db    *gorm.DB
	props users.CreateProps

	expectMock func() error
}

func createSetup(ctx context.Context, props users.CreateProps, prepareDB func(mock sqlmock.Sqlmock)) setup {
	db, mock, err := sqlmock.New()
	if err != nil {
		panic(err)
	}
	gdb, err := gorm.Open(postgres.New(postgres.Config{Conn: db}), &gorm.Config{})
	if err != nil {
		panic(err)
	}

	if prepareDB != nil {
		prepareDB(mock)
	}

	return setup{
		ctx:   ctx,
		db:    gdb,
		props: props,

		expectMock: mock.ExpectationsWereMet,
	}
}

func TestCreate(t *testing.T) {
	now := time.Date(2020, 7, 29, 8, 29, 0, 0, time.UTC)
	tnteardown := testhelpers.StubTimeNow(&now)
	defer tnteardown()
	ulid := "01FJ8QVKERZZ0ZXYM43TKEA8AG"
	uvteardown := testhelpers.StubULIDGenerator(ulid)
	defer uvteardown()
	pepper := "xxxxxxxxxxxxxxxxxxxxxxx"
	rsteardown := testhelpers.StubRandomStr(pepper)
	defer rsteardown()

	testCases := []struct {
		it string

		setup setup

		want    string
		wantErr string
	}{
		{
			it: "rejects missing fields",

			setup: createSetup(context.Background(), users.CreateProps{}, nil),

			want: "",
			wantErr: "The following fields are invalid: address1, city, country, email, " +
				"firstName, lastName, password, postalCode, province, username",
		},
		{
			it: "rejects invalid fields",

			setup: createSetup(context.Background(), users.CreateProps{
				Address1:   "x",
				City:       "x",
				Country:    "x",
				Email:      "asdf.com",
				FirstName:  "x",
				LastName:   "x",
				Password:   "aweoru",
				PostalCode: "1",
				Province:   "M",
				Username:   "!!!!!!!!",
			}, nil),

			want: "",
			wantErr: "The following fields are invalid: address1, city, country, email, " +
				"firstName, lastName, password, postalCode, province, username",
		},
		{
			it: "returns nil and error if it cannot create a user",

			setup: createSetup(context.Background(), users.CreateProps{
				Address1:   "123 Test Ln",
				City:       "Boston",
				Country:    "United States",
				Email:      "test@test.com",
				FirstName:  "Taylor",
				LastName:   "Twellman",
				Password:   "b1cycle-kickin",
				PostalCode: "02101",
				Province:   "MA",
				Username:   "ttwellman",
			}, func(mock sqlmock.Sqlmock) {
				mock.ExpectBegin()
				mock.ExpectExec(`INSERT INTO "users"`).WithArgs(
					ulid,
					sqlmock.AnyArg(),
					sqlmock.AnyArg(),
					nil,
					"ttwellman",
					"test@test.com",
					"Taylor",
					"Twellman",
					"123 Test Ln",
					nil,
					"Boston",
					"MA",
					"02101",
					"United States",
					false,
					0,
					sqlmock.AnyArg(),
					pepper,
				).WillReturnError(errors.New("couldn't do it"))
				mock.ExpectRollback()
			}),

			want:    "",
			wantErr: "There was an unexpected error creating the user",
		},
		{
			it: "returns ulid and nil if it creates the user",

			setup: createSetup(context.Background(), users.CreateProps{
				Address1:   "123 Test Ln",
				City:       "Boston",
				Country:    "United States",
				Email:      "test@test.com",
				FirstName:  "Taylor",
				LastName:   "Twellman",
				Password:   "b1cycle-kickin",
				PostalCode: "02101",
				Province:   "MA",
				Username:   "ttwellman",
			}, func(mock sqlmock.Sqlmock) {
				mock.ExpectBegin()
				mock.ExpectExec(`INSERT INTO "users"`).WithArgs(
					ulid,
					sqlmock.AnyArg(),
					sqlmock.AnyArg(),
					nil,
					"ttwellman",
					"test@test.com",
					"Taylor",
					"Twellman",
					"123 Test Ln",
					nil,
					"Boston",
					"MA",
					"02101",
					"United States",
					false,
					0,
					sqlmock.AnyArg(),
					pepper,
				).WillReturnResult(sqlmock.NewResult(1, 1))
				mock.ExpectCommit()
			}),

			want:    ulid,
			wantErr: "",
		},
	}

	t.Run("parallel group", func(g *testing.T) {
		for _, tc := range testCases {
			testCase := tc

			g.Run(testCase.it, func(test *testing.T) {
				test.Parallel()

				got, err := users.Create(testCase.setup.ctx, testCase.setup.db, testCase.setup.props)

				assert.NoError(test, testCase.setup.expectMock())
				if testCase.wantErr == "" {
					assert.NoError(test, err)
				} else {
					assert.Error(test, err, testCase.wantErr)
				}
				assert.Equal(test, testCase.want, got)
			})
		}
	})
}
