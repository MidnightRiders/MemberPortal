import { Redirect, Route, Switch } from 'wouter-preact';
import Home from '~routes/Home';
import SignIn from '~routes/SignIn';
import { useAuthCtx } from './contexts/auth';
import type { Route as Rte } from './makeRoute';

const unauthedRoutes: Rte[] = [];

const loggedOutRoutes: Rte[] = [SignIn];

const authedRoutes: Rte[] = [Home];

const RouteRedirect = ({ path, to }: { path: string; to: string }) => (
  <Route path={path}>
    <Redirect to={to} />
  </Route>
);

const Routes = () => {
  const { user } = useAuthCtx();

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
