package users

import (
	"context"
	"errors"
	"os"
	"regexp"
	"sort"
	"strings"

	"github.com/sirupsen/logrus"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"

	"github.com/MidnightRiders/MemberPortal/server/internal/graphql/model"
	"github.com/MidnightRiders/MemberPortal/server/internal/stubbables"
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
	var chars []string
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

const minPasswordLen = 12
const maxPasswordLen = 60

// PasswordIsValid validates a given password
func PasswordIsValid(password string) bool {
	if len(password) < minPasswordLen {
		return false
	}
	if len(password) > maxPasswordLen {
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

const pepperLen = 128

// Create creates a new user
func Create(ctx context.Context, db *gorm.DB, props CreateProps) (string, error) {
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
	pepper := stubbables.RandomStr(pepperLen)
	digest, err := bcrypt.GenerateFromPassword([]byte(props.Password+salt+pepper), bcrypt.DefaultCost)
	if err != nil {
		logrus.WithError(err).Error("Error generating digest from password")
		return "", errors.New("there was an unexpected error creating the user")
	}

	user := model.User{
		Username:   props.Username,
		Email:      props.Email,
		FirstName:  props.FirstName,
		LastName:   props.LastName,
		Address1:   props.Address1,
		Address2:   props.Address2,
		City:       props.City,
		Province:   &props.Province,
		PostalCode: props.PostalCode,
		Country:    props.Country,
		// TODO: props.MembershipNumber,

		PasswordDigest: string(digest),
		Pepper:         pepper,
	}

	result := db.WithContext(ctx).Create(&user)
	if err := result.Error; err != nil {
		logrus.WithError(err).Error("Error creating user")
		return "", errors.New("there was an unexpected error creating the user")
	}

	return user.ULID, nil
}
