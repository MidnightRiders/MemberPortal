import { createContext, FunctionComponent } from 'preact';
import cookies from 'js-cookie';

import {
  StateUpdater,
  useContext,
  useEffect,
  useMemo,
  useState,
} from 'preact/hooks';
import { noop } from '~helpers/utils';
import LogRocket from 'logrocket';

export interface BaseUser {
  id: number;
  memberSince: number | null;
  username: string;
}

type TimestampKeys<O> = {
  [K in keyof O]: K extends `${string}At` ? K : never;
}[keyof O];

export interface APIExpandedUser extends BaseUser {
  address: string | null;
  city: string | null;
  country: string | null;
  createdAt: string;
  email: string;
  firstName: string;
  isCurrentMember: boolean;
  lastName: string;
  phone: number;
  postalCode: string | null;
  state: string | null;
  stripeCustomerToken: string | null;
  updatedAt: string;
}

export type ExpandedUser = Omit<
  APIExpandedUser,
  TimestampKeys<APIExpandedUser>
> & {
  [K in TimestampKeys<APIExpandedUser>]: Date;
};

interface AuthContext {
  jwt: string | null;
  user: ExpandedUser | null;

  setJwt: (jwt: string | null) => void;
  setUser: StateUpdater<ExpandedUser | null>;
}

const AuthCtx = createContext<AuthContext>({
  jwt: null,
  user: null,

  setJwt: noop,
  setUser: noop,
});

export const useAuthCtx = () => useContext(AuthCtx);

export const COOKIE_NAME = 'mr-session-token';

export const AuthProvider: FunctionComponent = ({ children }): JSX.Element => {
  const [jwt, setJwt] = useState(() => cookies.get(COOKIE_NAME) ?? null);
  const [user, setUser] = useState<ExpandedUser | null>(null);

  useEffect(() => {
    if (jwt) {
      cookies.set(COOKIE_NAME, jwt, { expires: 7 });
    } else {
      cookies.remove(COOKIE_NAME);
      setUser(null);
    }
  }, [jwt]);

  useEffect(() => {
    if (!user) return;

    LogRocket.identify(user.id.toString(), { username: user.username });
  }, [user]);

  const value = useMemo(
    () => ({ jwt, user, setJwt, setUser }),
    [jwt, user, setJwt, setUser],
  );

  return <AuthCtx.Provider value={value}>{children}</AuthCtx.Provider>;
};
