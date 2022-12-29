import { createContext, FunctionComponent } from 'preact';
import { StateUpdater, useContext, useMemo, useState } from 'preact/hooks';
import { noop } from '~helpers/utils';
import { useOnMount } from '~shared/hooks/effects';

export interface BaseUser {
  id: number;
  memberSince: number;
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
  setUser: StateUpdater<ExpandedUser | null>;
}

const AuthCtx = createContext<AuthContext>({ user: null, setUser: noop });

export const useAuthCtx = () => useContext(AuthCtx);

export const AuthProvider: FunctionComponent = ({ children }) => {
  const [user, setUser] = useState<ExpandedUser | null>(null);

  useOnMount(async () => {
    const resp = await fetch('/api/user');
    const { user: apiUser } = (await resp.json()) as {
      user: APIExpandedUser | null;
    };
    if (apiUser === null) {
      setUser(null);
    } else {
      const newUser = Object.entries(apiUser).reduce(
        (u, [k, v]) => ({
          ...u,
          [k]: k.endsWith('At') && typeof v === 'string' ? new Date(v) : v,
        }),
        {} as ExpandedUser,
      );
      setUser(newUser);
    }
  });

  const value = useMemo(() => ({ user, setUser }), [user, setUser]);

  return <AuthCtx.Provider value={value}>{children}</AuthCtx.Provider>;
};
