import type { JSX } from 'preact';
import { useCallback, useState } from 'preact/hooks';
import { Redirect } from 'wouter-preact';
import Button from '~shared/components/Button';
import Block from '~shared/components/layout/Block';
import Column from '~shared/components/layout/Column';
import Row from '~shared/components/layout/Row';

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
    [username, password],
  );

  if (user) {
    return <Redirect to="/home" />;
  }

  return (
    <Row>
      <Column columns={6} center>
        <Block as="form" onSubmit={handleLogIn}>
          <Row center>
            <Column columns={4}>
              <label for="username">Username</label>
            </Column>
            <Column columns={8}>
              <input
                type="username"
                name="username"
                id="username"
                autocomplete="username"
                value={username}
                onInput={({ currentTarget: { value } }) => setUsername(value)}
              />
            </Column>
          </Row>
          <Row center>
            <Column columns={4}>
              <label for="password">Password</label>
            </Column>
            <Column columns={8}>
              <input
                type="password"
                name="password"
                id="password"
                autocomplete="password"
                value={password}
                onInput={({ currentTarget: { value } }) => setPassword(value)}
              />
            </Column>
          </Row>
          <Row>
            <Column columns={8} offset={4}>
              <Button
                leftIcon={<i class="fa-solid fa-sign-in fa-fw" />}
                type="submit"
              >
                Sign In
              </Button>
            </Column>
          </Row>
        </Block>
      </Column>
    </Row>
  );
});

export default SignIn;
