import { signal } from '@preact/signals';
import dayjs from 'dayjs';
import { matchLink, revsOpponent } from '~helpers/matches';
import { nextRevsMatch, pageTitle } from '~shared/signals/app';

const Header = () => {
  return (
    <header>
      <h1>
        <a href="/">Midnight Riders</a>
        <small>Member Portal</small>
      </h1>
      {pageTitle.value && <h2>{pageTitle}</h2>}
      {/* = yield(:header) */}
      <h5>Next Game:</h5>
      {nextRevsMatch.value ? (
        <a href={matchLink(nextRevsMatch.value)}>
          <img
            src={revsOpponent(nextRevsMatch.value)!.crest.thumb}
            title={revsOpponent(nextRevsMatch.value)!.name}
          />
          <h5>
            {dayjs(nextRevsMatch.value.kickoff).format('%A,')}
            {dayjs(nextRevsMatch.value.kickoff).format('%_m.%-d, %l:%M%P')}
            <br />
            {nextRevsMatch.value.location}
          </h5>
        </a>
      ) : (
        <h5> None Scheduled</h5>
      )}
    </header>
  );
};

export default Header;
