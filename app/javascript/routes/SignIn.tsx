import type { JSX } from 'preact';
import { useCallback, useState } from 'preact/hooks';
import { Redirect } from 'wouter-preact';

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
    <form onSubmit={handleLogIn}>
      <label for="username">Username</label>
      <input
        type="username"
        name="username"
        id="username"
        autocomplete="username"
        value={username}
        onInput={({ currentTarget: { value } }) => setUsername(value)}
      />
      <label for="password">Password</label>
      <input
        type="password"
        name="password"
        id="password"
        autocomplete="password"
        value={password}
        onInput={({ currentTarget: { value } }) => setPassword(value)}
      />
      <button type="submit">Sign In</button>
    </form>
  );
});

export default SignIn;
