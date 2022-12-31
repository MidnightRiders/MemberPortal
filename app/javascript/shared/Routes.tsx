import { Redirect, Route, Switch } from 'wouter-preact';
import Home from '~routes/Home';
import SignIn from '~routes/SignIn';

const RouteRedirect = ({ path, to }: { path: string; to: string }) => (
  <Route path={path}>
    <Redirect to={to} />
  </Route>
);

const Routes = () => (
  <Switch>
    <Route path={SignIn.path} component={SignIn} />
    <Route path={Home.path} component={Home} />
    <RouteRedirect path="/home" to={Home.path} />
  </Switch>
);

export default Routes;
