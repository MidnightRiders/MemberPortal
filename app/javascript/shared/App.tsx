import './root.css';

import type { FunctionComponent } from 'preact';
import { Router } from 'wouter-preact';

import { AuthProvider } from '~shared/contexts/auth';
import Routes from '~shared/Routes';
import { CacheProvider } from '~shared/contexts/cache';
import Header from '~shared/components/Header';
import { useOnMount } from '~shared/hooks/effects';
import { nextRevsMatch } from '~shared/signals/app';
import Navigation from '~shared/components/Navigation';
import { ErrorsProvider, useErrorsCtx } from '~shared/contexts/errors/errors';
import { useGet } from '~shared/contexts/errors/fetch';
import { Match } from '~helpers/matches';
import Footer from './components/Footer';

const App = () => {
  const getNextRevsMatch = useGet('nextRevsMatch');

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

  const { errors } = useErrorsCtx();

  return (
    <Router>
      <Header />
      <Navigation />
      {Object.entries(errors).map(([key, errs]) => (
        <div>
          {key}: {errs.map(({ message }) => message).join(', ')}
        </div>
      ))}
      <Routes />
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
