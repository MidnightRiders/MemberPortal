import { Route, Switch } from 'wouter-preact';
import SignIn from '~routes/SignIn';

const Routes = () => (
  <Switch>
    <Route path={SignIn.path} component={SignIn} />
  </Switch>
);

export default Routes;
