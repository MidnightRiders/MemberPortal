/*global React, PickEm*/
class Match extends React.Component {
  constructor(props) {
    super(props);

    this.isRevs = props.home_team.abbrv === 'NE' || props.away_team.abbrv === 'NE';
    this.kickoffInterval = null;

    this.motMUrl = `/matches/${this.props.id}/motm`;
    this.revGuessUrl = `/matches/${this.props.id}/rev_guess`;

    this.state = {
      canMakeRevGuess: this.canMakeRevGuess(),
      canVoteForMotM: this.canVoteForMotM(),
      past: props.kickoff < new Date()
    };
  }

  canVoteForMotM() {
    return this.isRevs &&
      this.props.kickoff < moment().subtract(45, 'minutes') &&         // at least 45 minutes ago
      this.props.kickoff > moment().subtract(2, 'weeks'); // less than two weeks ago
  }

  canMakeRevGuess() {
    return this.isRevs &&
      this.props.kickoff > new Date();
  }

  componentDidMount() {
    this.waitForGameProgress();
  }

  componentWillUnmount() {
    this.stopWaitingForGameProgress();
  }

  motM() {
    if (!this.state.canVoteForMotM) {
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

  revGuess() {
    if (!this.state.canMakeRevGuess) {
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
    if (this.kickoffInterval) {
      clearInterval(this.kickoffInterval);
      this.kickoffInterval = null;
    }
  }

  waitForGameProgress() {
    if (!this.state.past && !this.kickoffInterval) {
      this.kickoffInterval = setInterval(() => {
        if (!this.state.past && this.props.kickoff < new Date()) {
          this.setState({ past: true });
          if (this.isRevs) {
            this.setState({ canMakeRevGuess: false });
          } else {
            this.stopWaitingForGameProgress();
          }
        }
        if (this.state.past && this.canVoteForMotM()) {
          this.setState({ canVoteForMotM: true });
          this.stopWaitingForGameProgress();
        }
      }, 5000);
    }
  }

  render() {
    return (
      <li className={`match ${this.isRevs ? 'secondary-border ne' : ''} ${this.state.loading ? 'loading' : ''}`}>
        <time dateTime={this.props.kickoff.toISOString()}>
          <a href={`/matches/${this.props.id}`}>
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
