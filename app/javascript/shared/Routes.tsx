import { useEffect } from 'preact/hooks';
import { Redirect, Route, Switch, useLocation } from 'wouter-preact';

import Contact from '~routes/Contact';
import FAQ from '~routes/FAQ';
import Home from '~routes/Home';
import SignIn from '~routes/SignIn';
import SignUp from '~routes/SignUp';

import { useAuthCtx } from './contexts/auth';
import type { Route as Rte } from './makeRoute';

const unauthedRoutes: Rte[] = [Contact, FAQ];

const loggedOutRoutes: Rte[] = [SignIn, SignUp];

const authedRoutes: Rte[] = [Home];

const RouteRedirect = ({ path, to }: { path: string; to: string }) => (
  <Route path={path}>
    <Redirect to={to} />
  </Route>
);

const Routes = () => {
  const { user } = useAuthCtx();
  const [location] = useLocation();
  useEffect(() => {
    let currentScroll = window.scrollY;
    const scrollY = Math.min(
      currentScroll,
      document.querySelector('#root > header')?.clientHeight ?? 0,
    );
    if (scrollY === currentScroll) return undefined;

    const step = Math.max(1, Math.floor((currentScroll - scrollY) / 25));
    const intvl = setInterval(() => {
      currentScroll -= step;
      window.scrollTo(0, currentScroll);
      if (currentScroll <= scrollY) {
        window.scrollTo(0, scrollY);
        clearInterval(intvl);
      }
    }, 10);
    return () => {
      if (intvl) clearInterval(intvl);
    };
  }, [location]);

  return (
    <Switch>
      {user
        ? [
            ...loggedOutRoutes.map((r) => (
              <RouteRedirect path={r.path} to={Home.path} />
            )),
            ...unauthedRoutes.map((r) => <Route path={r.path} component={r} />),
            ...authedRoutes.map((r) => <Route path={r.path} component={r} />),
            <RouteRedirect path="/home" to={Home.path} />,
          ]
        : [
            ...authedRoutes.map((r) => (
              <RouteRedirect path={r.path} to={SignIn.path} />
            )),
            ...unauthedRoutes.map((r) => <Route path={r.path} component={r} />),
            ...loggedOutRoutes.map((r) => (
              <Route path={r.path} component={r} />
            )),
          ]}
    </Switch>
  );
};

export default Routes;
