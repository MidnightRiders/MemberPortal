import dayjs from 'dayjs';

import { revsOpponent } from '~helpers/matches';
import logo from '~shared/assets/logo.png';
import Link from '~shared/components/Link';
import Paths, { pathTo } from '~shared/paths';
import { nextRevsMatch, pageTitle } from '~shared/signals/app';

import styles from './styles.module.css';

const Header = () => (
  <header className={styles.pageHeader}>
    <h1>
      <Link href={Paths.Home}>
        <img src={logo} alt="Midnight Riders" />
      </Link>
      <small>{pageTitle.value ?? 'Member Portal'}</small>
    </h1>
    {/* = yield(:header) */}
    <div className={styles.nextMatch}>
      <h5>Next Game:</h5>
      {nextRevsMatch.value ? (
        <Link href={pathTo(Paths.Match, nextRevsMatch.value.id)}>
          <h5>
            {dayjs(nextRevsMatch.value.kickoff).format('dddd, M.D, h:ma')}
            <br />
            {nextRevsMatch.value.location}
          </h5>
          <img
            alt={revsOpponent(nextRevsMatch.value)!.name}
            title={revsOpponent(nextRevsMatch.value)!.name}
            src={revsOpponent(nextRevsMatch.value)!.crest.thumb}
          />
        </Link>
      ) : (
        <h5>None Scheduled</h5>
      )}
    </div>
  </header>
);

export default Header;
