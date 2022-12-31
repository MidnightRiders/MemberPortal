import { Typography } from 'antd';
import dayjs from 'dayjs';

import { matchLink, revsOpponent } from '~helpers/matches';
import { nextRevsMatch, pageTitle } from '~shared/signals/app';

const Header = () => {
  return (
    <header>
      <Typography.Title level={1}>
        <a href="/">Midnight Riders</a>
        <small>Member Portal</small>
      </Typography.Title>
      {pageTitle.value && (
        <Typography.Title level={2}>{pageTitle}</Typography.Title>
      )}
      {/* = yield(:header) */}
      <Typography.Title level={5}>Next Game:</Typography.Title>
      {nextRevsMatch.value ? (
        <a href={matchLink(nextRevsMatch.value)}>
          <img
            src={revsOpponent(nextRevsMatch.value)!.crest.thumb}
            title={revsOpponent(nextRevsMatch.value)!.name}
          />
          <Typography.Title level={5}>
            {dayjs(nextRevsMatch.value.kickoff).format('%A,')}
            {dayjs(nextRevsMatch.value.kickoff).format('%_m.%-d, %l:%M%P')}
            <br />
            {nextRevsMatch.value.location}
          </Typography.Title>
        </a>
      ) : (
        <Typography.Title level={5}> None Scheduled</Typography.Title>
      )}
    </header>
  );
};

export default Header;
