/*global React, PickEm*/
class Match extends React.Component {
  constructor(props) {
    super(props);

    this.isRevs = props.home_team.abbrv === 'NE' || props.away_team.abbrv === 'NE';
    this.kickoffTimeout = null;
    this.completionTimeout = null;
    this.resultPoll = null;

    this.matchUrl = `/matches/${this.props.id}`;
    this.motMUrl = `${this.matchUrl}/motm`;
    this.revGuessUrl = `${this.matchUrl}/rev_guess`;

    this.state = {
      live: this.isLive(),
      completed: this.isCompleted()
    };
  }

  canVoteForMotM() {
    return this.isRevs &&
      this.state.completed &&
      this.props.kickoff > moment().subtract(2, 'weeks'); // less than two weeks ago
  }

  canMakeRevGuess() {
    return this.isRevs && this.props.kickoff > new Date();
  }

  componentDidMount() {
    this.waitForGameProgress();
  }

  componentWillUnmount() {
    this.stopWaitingForGameProgress();
  }

  hasScore(match) {
    return !isNaN(parseInt(match.home_goals, 10)) && !isNaN(parseInt(match.away_goals, 10));
  }

  isCompleted() {
    return this.hasScore(this.props);
  }

  isLive() {
    return this.props.kickoff < new Date() && !this.isCompleted();
  }

  motM() {
    if (!this.canVoteForMotM()) {
      if (!this.isRevs) return '';
      return (
        <div className={`game-indicator game-indicator-motm ${this.props.mot_m ? 'completed' : ''}`}>
          <i className="fa fa-trophy fa-fw" />
        </div>
      );
    } else if (this.props.motMForDisplay) {
      return (
        <MotM
          updateMatch={this.props.updateMatch}
          exitHandler={this.props.clearGame}
          baseUrl={this.props.baseUrl}
          matchup={`${this.props.home_team.abbrv} v ${this.props.away_team.abbrv}`}
          {...this.props.motMForDisplay}
        />
      );
    } else {
      let showMotM = (e) => {
        e.preventDefault();

        this.setState({ loading: true });
        this.props.getMotM().done(() => { this.setState({ loading: false }); });
      };
      return (
        <a className={`game-indicator game-indicator-link game-indicator-motm ${this.props.mot_m ? 'completed' : ''}`} href={this.motMUrl} onClick={showMotM} title='Man of the Match'>
          <i className="fa fa-trophy fa-fw" />
        </a>
      );
    }
  }

  pollForResult() {
    this.resultPoll = setInterval(() => {
      jQuery.getJSON(this.matchUrl)
        .then((match) => {
          if (this.hasScore(match)) return;
          this.props.updateMatch(match);
          clearInterval(this.resultPoll);
          this.resultPoll = null;
        });
    }, 60 * 1000 * 5);
  }

  revGuess() {
    if (!this.canMakeRevGuess()) {
      if (!this.isRevs) return '';
      return (
        <div className={`game-indicator game-indicator-rev-guess ${this.props.mot_m ? 'completed' : ''}`}>
          <i className="fa fa-balance-scale fa-fw" />
        </div>
      );
    } else if (this.props.revGuessForDisplay) {
      return (
        <RevGuess
          match_id={this.props.id}
          exitHandler={this.props.clearGame}
          baseUrl={this.props.baseUrl}
          updateMatch={this.props.updateMatch}
          home_team={this.props.home_team}
          away_team={this.props.away_team}
          {...this.props.revGuessForDisplay}
        />
      );
    } else {
      let showRevGuess = (e) => {
        e.preventDefault();

        this.setState({ loading: true });
        this.props.getRevGuess().done(() => { this.setState({ loading: false }); });
      };
      return (
        <a className={`game-indicator game-indicator-link game-indicator-rev-guess ${this.props.rev_guess ? 'completed' : ''}`} href={this.revGuessUrl} onClick={showRevGuess} title='RevGuess'>
          <i className="fa fa-balance-scale fa-fw" />
        </a>
      );
    }
  }

  stopWaitingForGameProgress() {
    if (this.kickoffTimeout) {
      clearTimeout(this.kickoffTimeout);
      this.kickoffTimeout = null;
    }
    if (this.completionTimeout) {
      clearTimeout(this.completionTimeout);
      this.completionTimeout = null;
    }
    if (this.resultPoll) {
      clearInterval(this.resultPoll);
      this.resultPoll = null;
    }
  }

  waitForGameProgress() {
    if (this.state.completed) return;

    if (!this.state.live) {
      this.kickoffTimeout = setTimeout(() => {
        this.setState({ live: true });
      }, - moment(this.props.kickoff).diff(new Date()));
    }

    this.completionTimeout = setTimeout(() => {
      this.pollForResult();
    }, - moment(this.props.kickoff).add(105, 'minutes').diff(new Date()));
  }

  classNames() {
    return [
      'match',
      this.isRevs ? 'secondary-border ne' : null,
      this.state.loading ? 'loading' : null,
      this.state.live ? 'live' : null,
      this.state.completed ? 'completed' : null
    ].filter((e) => !!e).join(' ');
  }

  render() {
    return (
      <li className={this.classNames()} data-match-id={this.props.id}>
        <time dateTime={this.props.kickoff.toISOString()}>
          <a href={this.matchUrl}>
            {moment(this.props.kickoff).format('M.D h:mma')}
            <sup><i className="fa fa-info-circle"/></sup>
          </a>
        </time>
        <div className="pick-em-container">
          <PickEm
            key={`pick-em-for-${this.props.id}`}
            match_id={this.props.id}
            home_team={this.props.home_team}
            away_team={this.props.away_team}
            home_goals={this.props.home_goals}
            away_goals={this.props.away_goals}
            pick={this.props.pick}
            past={this.state.past}
          />
          {this.revGuess()}
          {this.motM()}
        </div>
      </li>
    );
  }
}

Match.propTypes = {
  id: React.PropTypes.number.isRequired,
  home_team: React.PropTypes.object.isRequired,
  away_team: React.PropTypes.object.isRequired,
  home_goals: React.PropTypes.number,
  away_goals: React.PropTypes.number,
  pick: React.PropTypes.string,
  kickoff: React.PropTypes.instanceOf(Date).isRequired,
  location: React.PropTypes.string.isRequired,
  getMotM: React.PropTypes.func,
  getRevGuess: React.PropTypes.func,
  clearGame: React.PropTypes.func.isRequired,
  updateMatch: React.PropTypes.func.isRequired,
  motMForDisplay: React.PropTypes.object,
  revGuessForDisplay: React.PropTypes.object,
  mot_m: React.PropTypes.object,
  rev_guess: React.PropTypes.object,
  baseUrl: React.PropTypes.string.isRequired
};
