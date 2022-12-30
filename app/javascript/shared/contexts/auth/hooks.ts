import { useCallback } from 'preact/hooks';

import { useDel, usePost } from '../errors/fetch';
import { APIExpandedUser, ExpandedUser, useAuthCtx } from '.';
import { FetchError } from '~helpers/fetch';
import { setUser } from '@sentry/browser';

export const userFromApi = (apiUser: APIExpandedUser): ExpandedUser =>
  Object.entries(apiUser).reduce(
    (u, [k, v]) => ({
      ...u,
      [k]: k.endsWith('At') && typeof v === 'string' ? new Date(v) : v,
    }),
    {} as ExpandedUser,
  );

export const useLogIn = () => {
  const { setUser } = useAuthCtx();

  const createSession = usePost(
    'signIn',
    {
      customMessage: (err) => {
        if (err instanceof FetchError) {
          if (err.status === 401) {
            return 'Invalid username or password';
          }
          return err.message;
        }
        if (process.env.RAILS_ENV === 'development') {
          console.error(err);
        }
        return 'An unknown error occurred';
      },
    },
    [],
  );

  const logIn = useCallback(async (username: string, password: string) => {
    const resp = await createSession<{ user: APIExpandedUser; jwt: string }>(
      '/api/sessions',
      { username, password },
    );
    if (!resp) return;

    setUser(userFromApi(resp.user));
  }, []);

  return logIn;
};

export const useLogOut = () => {
  const { setJwt } = useAuthCtx();

  const delSession = useDel('signOut');
  const logOut = useCallback(async () => {
    if (await delSession<true>('/api/sessions')) {
      setJwt(null);
    }
  }, []);

  return logOut;
};
