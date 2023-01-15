import dayjs from 'dayjs';
import { Link } from 'wouter-preact';

import logo from '~shared/assets/logo.png';
import { revsOpponent } from '~helpers/matches';
import { nextRevsMatch, pageTitle } from '~shared/signals/app';
import Paths, { pathTo } from '~shared/paths';

import styles from './styles.module.css';

const Header = () => (
  <header class={styles.pageHeader}>
    <h1>
      <Link href={Paths.Home}>
        <a>
          <img src={logo} alt="Midnight Riders" />
        </a>
      </Link>
      <small>{pageTitle.value ?? 'Member Portal'}</small>
    </h1>
    {/* = yield(:header) */}
    <div class={styles.nextMatch}>
      <h5>Next Game:</h5>
      {nextRevsMatch.value ? (
        <Link href={pathTo(Paths.Match, nextRevsMatch.value.id)}>
          <a>
            <h5>
              {dayjs(nextRevsMatch.value.kickoff).format('dddd, M.D, h:ma')}
              <br />
              {nextRevsMatch.value.location}
            </h5>
            <img
              src={revsOpponent(nextRevsMatch.value)!.crest.thumb}
              title={revsOpponent(nextRevsMatch.value)!.name}
            />
          </a>
        </Link>
      ) : (
        <h5>None Scheduled</h5>
      )}
    </div>
  </header>
);

export default Header;
