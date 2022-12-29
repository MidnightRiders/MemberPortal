import { createContext, FunctionComponent } from 'preact';
import {
  StateUpdater,
  useCallback,
  useContext,
  useMemo,
  useState,
} from 'preact/hooks';
import { noop } from '~helpers/utils';
import { useOnMount } from '~shared/hooks/effects';
import { useDel, useGet } from '../errors/fetch';

export interface BaseUser {
  id: number;
  memberSince: number | null;
  username: string;
}

type TimestampKeys<O> = {
  [K in keyof O]: K extends `${string}At` ? K : never;
}[keyof O];

interface APIExpandedUser extends BaseUser {
  address: string | null;
  city: string | null;
  country: string | null;
  createdAt: string;
  email: string;
  firstName: string;
  isCurrentUser: boolean;
  lastName: string;
  phone: number;
  postalCode: string | null;
  state: string | null;
  stripeCustomerToken: string | null;
  updatedAt: string;
}

type ExpandedUser = Omit<APIExpandedUser, TimestampKeys<APIExpandedUser>> & {
  [K in TimestampKeys<APIExpandedUser>]: Date;
};

interface AuthContext {
  user: ExpandedUser | null;

  logOut: () => void;
  setUser: StateUpdater<ExpandedUser | null>;
}

const AuthCtx = createContext<AuthContext>({
  user: null,
  logOut: noop,
  setUser: noop,
});

export const useAuthCtx = () => useContext(AuthCtx);

export const AuthProvider: FunctionComponent = ({ children }) => {
  const [user, setUser] = useState<ExpandedUser | null>(null);

  const getUser = useGet('fetchUser');

  useOnMount(async () => {
    const resp = await getUser<{ user: APIExpandedUser | null }>('/api/user');
    if (resp && resp.user) {
      const newUser = Object.entries(resp.user).reduce(
        (u, [k, v]) => ({
          ...u,
          [k]: k.endsWith('At') && typeof v === 'string' ? new Date(v) : v,
        }),
        {} as ExpandedUser,
      );
      setUser(newUser);
    } else {
      setUser(null);
    }
  });

  const delSession = useDel('signOut');
  const logOut = useCallback(async () => {
    if (await delSession<true>('/users/sign_out')) {
      setUser(null);
    }
  }, []);

  const value = useMemo(
    () => ({ user, logOut, setUser }),
    [user, logOut, setUser],
  );

  return <AuthCtx.Provider value={value}>{children}</AuthCtx.Provider>;
};
