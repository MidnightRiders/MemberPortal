import './root.css';

import { Router } from 'wouter-preact';
import { AuthProvider } from './contexts/auth';

import Routes from './Routes';

const App = () => (
  <AuthProvider>
    <Router>
      <Routes />
    </Router>
  </AuthProvider>
);

export default App;
