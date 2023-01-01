import './root.css';

import { ConfigProvider, Layout } from 'antd';
import { Router } from 'wouter-preact';

import {
  APIExpandedUser,
  AuthProvider,
  useAuthCtx,
} from '~shared/contexts/auth';
import Routes from '~shared/Routes';
import { CacheProvider } from '~shared/contexts/cache';
import Header from '~shared/components/Header';
import { useOnMount } from '~shared/hooks/effects';
import { nextRevsMatch, pageTitle } from '~shared/signals/app';
import Navigation from '~shared/components/Navigation';
import { ErrorsProvider } from '~shared/contexts/errors';
import { useGet } from '~shared/contexts/errors/fetch';
import { Match } from '~helpers/matches';
import Footer from '~shared/components/Footer';
import { FetchError } from '~helpers/fetch';
import { userFromApi } from '~shared/contexts/auth/hooks';
import theme from '~shared/theme';

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
      <Layout>
        <Header />
        <Layout.Header>
          <Navigation />
        </Layout.Header>
        <Layout.Content>
          <Routes />
        </Layout.Content>
        <Layout.Footer>
          <Footer />
        </Layout.Footer>
      </Layout>
    </Router>
  );
};

const AppWithContexts = () => (
  <ConfigProvider theme={theme}>
    <ErrorsProvider>
      <CacheProvider>
        <AuthProvider>
          <App />
        </AuthProvider>
      </CacheProvider>
    </ErrorsProvider>
  </ConfigProvider>
);

export default AppWithContexts;
