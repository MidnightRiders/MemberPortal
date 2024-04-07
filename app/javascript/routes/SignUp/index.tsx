import { useCallback, useEffect, useState } from 'preact/hooks';
import { Redirect, useLocation } from 'wouter-preact';

import Button from '~shared/components/Button';
import Actions from '~shared/components/forms/Actions';
import Input from '~shared/components/forms/Input';
import InputGroup from '~shared/components/forms/InputGroup';
import useForm, { type Field } from '~shared/components/forms/useForm';
import Block from '~shared/components/layout/Block';
import Callout from '~shared/components/layout/Callout';
import Column from '~shared/components/layout/Column';
import Row from '~shared/components/layout/Row';
import { type APIExpandedUser, useAuthCtx } from '~shared/contexts/auth';
import { userFromApi } from '~shared/contexts/auth/hooks';
import makeRoute from '~shared/makeRoute';
import Paths, { pathTo } from '~shared/paths';

const thisYear = new Date().getFullYear() + (new Date().getMonth() >= 10 ? 1 : 0);

const fields = {
  firstName: '',
  lastName: '',
  memberSince: { value: thisYear, optional: true },
  username: '',
  password: '',
  email: '',
  streetAddress: '',
  city: '',
  state: '',
  postalCode: '',
  country: 'USA',
} satisfies Record<string, Field<string | number>>;

const SignUp = makeRoute(Paths.SignUp, () => {
  const { setUser, user } = useAuthCtx();
  const [, setLocation] = useLocation();

  const [
    { firstName, lastName, memberSince, username, password, email, streetAddress, city, state, postalCode, country },
    [
      setFirstName,
      setLastName,
      setMemberSince,
      setUsername,
      setPassword,
      setEmail,
      setStreetAddress,
      setCity,
      setState,
      setPostalCode,
      setCountry,
    ],
    handleSubmit,
  ] = useForm<{ user: APIExpandedUser }, typeof fields>('/api/users', fields, {
    onSubmit: ({ user: u }) => {
      setLocation(pathTo(Paths.UserNewMembership, u.id));
      setUser(userFromApi(u));
    },
    constructBody: (userValues) => ({ user: userValues }),
  });

  const [hasEditedUsername, setHasEditedUsername] = useState(false);
  const updateUsername = useCallback((v: string) => {
    setHasEditedUsername(true);
    setUsername(v);
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    if (hasEditedUsername) return;
    if (!firstName && !lastName) return;

    setUsername(
      [firstName.toLocaleLowerCase().replace(/\s+/g, ''), lastName.toLocaleLowerCase().replace(/\s+/g, '')].join(''),
    );
  }, [firstName, lastName]); // eslint-disable-line react-hooks/exhaustive-deps

  if (user) {
    if (user.isCurrentMember) {
      return <Redirect to={Paths.Home} />;
    }
    return <Redirect to={pathTo(Paths.UserNewMembership, user.id)} />;
  }

  return (
    <form action="/api/users" method="post" onSubmit={handleSubmit}>
      <Row>
        <Column size={3}>
          <h2 className="white">User Information</h2>
        </Column>
        <Column size={9}>
          <Block>
            <InputGroup
              label="Name"
              size={[
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
              options={Array.from({ length: thisYear - 1995 + 1 }, (_, i) => (1995 + i).toString()).map((year) => ({
                value: year,
                label: year,
              }))}
              name="memberSince"
              value={memberSince}
              setValue={setMemberSince}
            />
            <Input
              autocomplete="username"
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
              autocomplete="new-password"
              type="password"
              value={password}
              setValue={setPassword}
              label="Password"
              name="password"
              minLength={12}
              maxLength={128}
              required
            />
          </Block>
        </Column>
      </Row>
      <Row>
        <Column size={3}>
          <h2 className="white">Contact Information</h2>
          <Callout as="p">
            <strong>We need your address</strong> to be able to send you your membership package.
          </Callout>
        </Column>
        <Column size={9}>
          <Block>
            <Input name="email" type="email" value={email} setValue={setEmail} label="Email" required />
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
              size={[
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
                  size: 2,
                },
                {
                  name: 'postalCode',
                  value: postalCode,
                  setValue: setPostalCode,
                  placeholder: 'Postal Code',
                  required: true,
                  size: 3,
                },
                {
                  name: 'country',
                  value: country,
                  setValue: setCountry,
                  placeholder: 'Country',
                  required: true,
                  size: 3,
                },
              ]}
            />
          </Block>
        </Column>
      </Row>
      <Actions sizes={[3, 9]}>
        <Button type="submit" leftIcon="person-fill-add">
          Sign Up
        </Button>
      </Actions>
    </form>
  );
});

export default SignUp;
