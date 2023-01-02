import dayjs from 'dayjs';

import { matchLink, revsOpponent } from '~helpers/matches';
import { nextRevsMatch, pageTitle } from '~shared/signals/app';
import { H1, H2, H5 } from '~shared/components/typography';

const Header = () => {
  return (
    <header>
      <H1>
        <a href="/">Midnight Riders</a>
        <small>Member Portal</small>
      </H1>
      {pageTitle.value && <H2>{pageTitle.value}</H2>}
      {/* = yield(:header) */}
      <H5>Next Game:</H5>
      {nextRevsMatch.value ? (
        <a href={matchLink(nextRevsMatch.value)}>
          <img
            src={revsOpponent(nextRevsMatch.value)!.crest.thumb}
            title={revsOpponent(nextRevsMatch.value)!.name}
          />
          <H5>
            {dayjs(nextRevsMatch.value.kickoff).format('%A,')}
            {dayjs(nextRevsMatch.value.kickoff).format('%_m.%-d, %l:%M%P')}
            <br />
            {nextRevsMatch.value.location}
          </H5>
        </a>
      ) : (
        <H5>None Scheduled</H5>
      )}
    </header>
  );
};

export default Header;
