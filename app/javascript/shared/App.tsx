import './root.css';

import { Router } from 'wouter-preact';

import { FetchError } from '~helpers/fetch';
import { Match } from '~helpers/matches';
import Footer from '~shared/components/Footer';
import Header from '~shared/components/Header';
import Navigation from '~shared/components/Navigation';
import {
  APIExpandedUser,
  AuthProvider,
  useAuthCtx,
} from '~shared/contexts/auth';
import { userFromApi } from '~shared/contexts/auth/hooks';
import { CacheProvider } from '~shared/contexts/cache';
import { ErrorsProvider } from '~shared/contexts/errors';
import { useGet } from '~shared/contexts/errors/fetch';
import { useOnMount } from '~shared/hooks/effects';
import Routes from '~shared/Routes';
import { nextRevsMatch, pageTitle } from '~shared/signals/app';

const ignoreUnauthed = (err: unknown) =>
  err instanceof FetchError && err.status === 401;

const App = () => {
  const getNextRevsMatch = useGet('nextRevsMatch');

  pageTitle.subscribe((title) => {
    document.title = `Midnight Riders | ${title}`;
  });

  useOnMount(() => {
    const updateNextRevsMatch = async () => {
      const resp = await getNextRevsMatch<{ match: Match }>(
        '/api/matches/next_revs_match',
      );
      nextRevsMatch.value = resp ? resp.match : null;
    };
    const poll = setInterval(() => {
      updateNextRevsMatch();
    }, 1_000 * 60 * 60);
    updateNextRevsMatch();

    return () => clearInterval(poll);
  });

  const { setUser } = useAuthCtx();

  const getUser = useGet('fetchUser', { ignore: ignoreUnauthed }, []);
  useOnMount(async () => {
    const resp = await getUser<{ user: APIExpandedUser | null }>('/api/user');
    if (resp && resp.user) {
      setUser(userFromApi(resp.user));
    }
  });

  return (
    <Router>
      <Header />
      <Navigation />
      <div className="pageContainer">
        <Routes />
      </div>
      <Footer />
    </Router>
  );
};

const AppWithContexts = () => (
  <ErrorsProvider>
    <CacheProvider>
      <AuthProvider>
        <App />
      </AuthProvider>
    </CacheProvider>
  </ErrorsProvider>
);

export default AppWithContexts;
