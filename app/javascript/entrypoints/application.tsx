import { render } from 'preact';
import * as Sentry from '@sentry/browser';
import LogRocket from 'logrocket';

import App from '~shared/App';

if (process.env.RAILS_ENV === 'production') {
  LogRocket.init('nqhpme/midnight-riders-member-portal');
}

Sentry.init({
  dsn: 'https://bc9541d68fb243c89e2d97f20e2148fe@o4504330520100864.ingest.sentry.io/4504330521870336',
  environment: process.env.RAILS_ENV!,
  enabled: process.env.RAILS_ENV === 'production',

  tracesSampleRate: 0.2,
});

render(<App />, document.body.querySelector('#root')!);

// Example: Load Rails libraries in Vite.
//
// import * as Turbo from '@hotwired/turbo'
// Turbo.start()
//
// import ActiveStorage from '@rails/activestorage'
// ActiveStorage.start()
//
// // Import all channels.
// const channels = import.meta.globEager('./**/*_channel.js')

// Example: Import a stylesheet in app/frontend/index.css
// import '~/index.css'
