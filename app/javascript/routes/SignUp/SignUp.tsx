import { useCallback, useEffect, useState } from 'preact/hooks';
import Button from '~shared/components/Button';
import Actions from '~shared/components/forms/Actions';
import Input from '~shared/components/forms/Input';
import InputGroup from '~shared/components/forms/InputGroup';
import useForm from '~shared/components/forms/useForm';
import Block from '~shared/components/layout/Block';
import Column from '~shared/components/layout/Column';
import Row from '~shared/components/layout/Row';
import makeRoute from '~shared/makeRoute';
import Paths from '~shared/paths';

const thisYear =
  new Date().getFullYear() + (new Date().getMonth() >= 10 ? 1 : 0);

const SignUp = makeRoute(Paths.SignUp, () => {
  const [
    {
      firstName,
      lastName,
      memberSince,
      username,
      password,
      passwordConfirmation,
      email,
      streetAddress,
      city,
      state,
      postalCode,
      country,
    },
    [
      setFirstName,
      setLastName,
      setMemberSince,
      setUsername,
      setPassword,
      setPasswordConfirmation,
      setEmail,
      setStreetAddress,
      setCity,
      setState,
      setPostalCode,
      setCountry,
    ],
    handleSubmit,
  ] = useForm(
    '/users',
    {
      firstName: '',
      lastName: '',
      memberSince: thisYear,
      username: '',
      password: '',
      passwordConfirmation: '',
      email: '',
      streetAddress: '',
      city: '',
      state: '',
      postalCode: '',
      country: 'USA',
    },
    (data) => {
      // TODO
    },
    (error) => {
      // TODO
    },
  );

  const [hasEditedUsername, setHasEditedUsername] = useState(false);
  const updateUsername = useCallback((v: string) => {
    setHasEditedUsername(true);
    setUsername(v);
  }, []);

  useEffect(() => {
    if (hasEditedUsername) return;
    if (!firstName && !lastName) return;

    setUsername(
      [
        firstName.toLocaleLowerCase().replace(/\s+/g, ''),
        lastName.toLocaleLowerCase().replace(/\s+/g, ''),
      ].join('.'),
    );
  }, [firstName, lastName]);

  return (
    <form action="/users" method="post" onSubmit={handleSubmit}>
      <Row>
        <Column columns={3}>
          <h2 class="white">User Information</h2>
        </Column>
        <Column columns={9}>
          <Block>
            <InputGroup
              label="Name"
              fields={[
                {
                  name: 'firstName',
                  value: firstName,
                  setValue: setFirstName,
                  placeholder: 'First Name',
                  required: true,
                },
                {
                  name: 'lastName',
                  value: lastName,
                  setValue: setLastName,
                  placeholder: 'Last Name',
                  required: true,
                },
              ]}
            />
            <Input
              label="Member Since"
              type="select"
              options={Array.from({ length: thisYear - 1995 + 1 }, (_, i) =>
                (1995 + i).toString(),
              ).map((year) => ({ value: year, label: year }))}
              name="memberSince"
              value={memberSince}
              setValue={setMemberSince}
            />
            <Input
              type="text"
              value={username}
              setValue={updateUsername}
              label="Username"
              name="username"
              minLength={8}
              maxLength={128}
              required
            />
            <Input
              type="password"
              value={password}
              setValue={setPassword}
              label="Password"
              name="password"
              minLength={12}
              maxLength={128}
              required
            />
            <Input
              type="password"
              value={passwordConfirmation}
              setValue={setPasswordConfirmation}
              label="Password Confirmation"
              name="passwordConfirmation"
              minLength={12}
              maxLength={128}
              required
            />
          </Block>
        </Column>
      </Row>
      <Row>
        <Column columns={3}>
          <h2 class="white">Contact Information</h2>
        </Column>
        <Column columns={9}>
          <Block>
            <Input
              name="email"
              type="email"
              value={email}
              setValue={setEmail}
              label="Email"
              required
            />
            <Input
              type="textarea"
              value={streetAddress}
              setValue={setStreetAddress}
              label="Street Address"
              name="streetAddress"
              required
              placeholder="123 Main St"
              rows={2}
            />
            <InputGroup
              fields={[
                {
                  name: 'city',
                  value: city,
                  setValue: setCity,
                  placeholder: 'City',
                  required: true,
                },
                {
                  name: 'state',
                  value: state,
                  setValue: setState,
                  placeholder: 'State',
                  required: true,
                  minLength: 2,
                  maxLength: 3,
                  columns: 2,
                },
                {
                  name: 'postalCode',
                  value: postalCode,
                  setValue: setPostalCode,
                  placeholder: 'Postal Code',
                  required: true,
                  columns: 3,
                },
                {
                  name: 'country',
                  value: country,
                  setValue: setCountry,
                  placeholder: 'Country',
                  required: true,
                  columns: 3,
                },
              ]}
            />
          </Block>
        </Column>
      </Row>
      <Actions columns={[3, 9]}>
        <Button type="submit" leftFa="user-plus">
          Sign Up
        </Button>
      </Actions>
    </form>
  );
});

export default SignUp;
