package users

import (
	"context"
	"database/sql"
	"errors"
	"os"
	"regexp"
	"sort"
	"strings"

	"github.com/MidnightRiders/MemberPortal/server/internal/stubbables"
	"github.com/sirupsen/logrus"
	"golang.org/x/crypto/bcrypt"
)

var letters = func() string {
	str := ""
	for x := 'a'; x <= 'z'; x++ {
		str += string(x)
	}
	return str + strings.ToUpper(str)
}()

var nonLetters = " 1234567890-=_+`;',./[]\\<>?:\"{}|~!@#$%^&*()"

var legalChars = func() []string {
	chars := []string{}
	for _, c := range letters {
		chars = append(chars, string(c), "")
	}
	for _, c := range nonLetters {
		chars = append(chars, string(c), "")
	}
	return chars
}()

var legalCharReplacer = strings.NewReplacer(legalChars...)

var usernameRegexp = regexp.MustCompile(`(?i)^[a-z0-9-_\.]{8,24}$`)

// PasswordIsValid validates a given password
func PasswordIsValid(password string) bool {
	if len(password) < 12 {
		return false
	}
	if len(password) > 60 {
		return false
	}
	if !strings.ContainsAny(password, letters) {
		return false
	}
	if !strings.ContainsAny(password, nonLetters) {
		return false
	}
	if len(legalCharReplacer.Replace(password)) > 0 {
		return false
	}
	return true
}

// CreateProps describe the information to be passed to Create
type CreateProps struct {
	Address1   string
	Address2   *string
	City       string
	Country    string
	Email      string
	FirstName  string
	LastName   string
	Password   string
	PostalCode string
	Province   string
	Username   string
}

var emailRegexp = regexp.MustCompile("^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\\.[a-zA-Z0-9-]+)*$")

type CreateUserError struct {
	InvalidFields []string
}

func (e *CreateUserError) Error() string {
	sort.Strings(e.InvalidFields)
	return "The following fields are invalid: " + strings.Join(e.InvalidFields, ", ")
}

func (e *CreateUserError) AddInvalidField(field string) {
	e.InvalidFields = append(e.InvalidFields, field)
}

// Create creates a new user
func Create(ctx context.Context, db *sql.DB, props CreateProps) (string, error) {
	var validationErr *CreateUserError
	for name, valid := range map[string]bool{
		"username":   usernameRegexp.MatchString(props.Username),
		"email":      emailRegexp.MatchString(props.Email),
		"password":   PasswordIsValid(props.Password),
		"firstName":  len(props.FirstName) >= 2,
		"lastName":   len(props.LastName) >= 2,
		"address1":   len(props.LastName) >= 2,
		"city":       len(props.City) >= 2,
		"province":   len(props.Province) >= 2,
		"postalCode": len(props.PostalCode) >= 2,
		"country":    len(props.Country) >= 2,
	} {
		if !valid {
			if validationErr == nil {
				validationErr = &CreateUserError{}
			}
			validationErr.AddInvalidField(name)
		}
	}

	if validationErr != nil {
		return "", validationErr
	}

	salt := os.Getenv("PASSWORD_SALT")
	pepper := stubbables.RandomStr(128)
	digest, err := bcrypt.GenerateFromPassword([]byte(props.Password+salt+pepper), bcrypt.DefaultCost)
	if err != nil {
		logrus.WithError(err).Error("Error generating digest from password")
		return "", errors.New("There was an unexpected error creating the user")
	}

	uuid := stubbables.UUIDv1()
	result, err := db.ExecContext(
		ctx,
		"INSERT INTO users "+
			"(uuid, username, email, password_digest, pepper, first_name, last_name, address1, address2, city, province, postal_code, country) "+
			"VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
		uuid, props.Username, props.Email, digest, pepper, props.FirstName, props.LastName, props.Address1, props.Address2, props.City, props.Province, props.PostalCode, props.Country, // TODO: props.MembershipNumber,
	)
	if err != nil {
		logrus.WithError(err).Error("Error creating user")
		return "", errors.New("There was an unexpected error creating the user")
	}
	if rows, err := result.RowsAffected(); err != nil || rows == 0 {
		logrus.WithError(err).WithField("rows", rows).Error("Error getting affected rows")
		return "", errors.New("There was an unexpected error creating the user")
	}

	return uuid, nil
}
