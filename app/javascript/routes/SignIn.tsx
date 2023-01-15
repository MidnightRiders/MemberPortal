import type { JSX } from 'preact';
import { useCallback, useState } from 'preact/hooks';
import { Redirect } from 'wouter-preact';

import Button from '~shared/components/Button';
import Actions from '~shared/components/forms/Actions';
import Input from '~shared/components/forms/Input';
import Block from '~shared/components/layout/Block';
import Column from '~shared/components/layout/Column';
import Row from '~shared/components/layout/Row';
import Link from '~shared/components/Link';
import { useAuthCtx } from '~shared/contexts/auth';
import { useLogIn } from '~shared/contexts/auth/hooks';
import { useErrorsCtx } from '~shared/contexts/errors';
import makeRoute from '~shared/makeRoute';
import Paths from '~shared/paths';

const SignIn = makeRoute(Paths.SignIn, () => {
  const { user } = useAuthCtx();
  const logIn = useLogIn();
  const { addError } = useErrorsCtx();

  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');

  const handleLogIn: JSX.GenericEventHandler<HTMLFormElement> = useCallback(
    (e) => {
      e.preventDefault();
      if (!username || !password) {
        addError('login', 'Please enter your username and password.');
        return;
      }

      logIn(username, password);
    },
    [username, password], // eslint-disable-line react-hooks/exhaustive-deps
  );

  if (user) {
    return <Redirect to="/home" />;
  }

  return (
    <Row>
      <Column columns={6} center>
        <Block as="form" onSubmit={handleLogIn}>
          <Input
            label="Username"
            value={username}
            setValue={setUsername}
            name="username"
            autocomplete="username"
          />
          <Input
            type="password"
            name="password"
            label="Password"
            autocomplete="current-password"
            value={password}
            setValue={setPassword}
          />
          <Actions>
            <Button leftIcon="box-arrow-in-right" type="submit">
              Sign In
            </Button>
            <Button
              as={Link}
              href={Paths.SignUp}
              secondary
              leftIcon="pencil-fill"
            >
              Sign Up
            </Button>
          </Actions>
        </Block>
      </Column>
    </Row>
  );
});

export default SignIn;
