/*global React, PickEm*/
class Match extends React.Component {
  constructor(props) {
    super(props);

    this.isRevs = props.home_team.abbrv === 'NE' || props.away_team.abbrv === 'NE';
    this.kickoffInterval = null;
    this.popstateCallback = null;

    this.motMUrl = `/matches/${this.props.id}/motm`;
    this.revGuessUrl = `/matches/${this.props.id}/revguess`;
    this.selfUrl = `/matches?date=${props.kickoff.getFullYear()}` +
      `-${`0${props.kickoff.getMonth() + 1}`.substr(-2, 2)}` +
      `-${`0${props.kickoff.getDate()}`.substr(-2, 2)}`;

    this.state = {
      canMakeRevGuess: this.canMakeRevGuess(),
      canVoteForMotM: this.canVoteForMotM(),
      past: props.kickoff < new Date()
    };
  }

  canVoteForMotM() {
    return this.isRevs &&
      this.props.kickoff < new Date() - 1000 * 60 * 45 &&         // at least 45 minutes ago
      this.props.kickoff > new Date() - 1000 * 60 * 60 * 24 * 14; // less than two weeks ago
  }

  canMakeRevGuess() {
    return this.isRevs &&
      this.props.kickoff > new Date();
  }

  componentDidMount() {
    this.waitForGameProgress();
    let callback;
    if (window.onpopstate) callback = window.onpopstate;
    window.onpopstate = () => { this.navigate.call(this, callback); };
  }

  componentWillUnmount() {
    this.stopWaitingForGameProgress();
  }

  formatKickoff() {
    let hour    = this.props.kickoff.getHours(),
        minutes = `0${this.props.kickoff.getMinutes()}`.substr(-2),
        amPm    = hour > 11 ? 'pm' : 'am';
    if (hour === 0) hour = 12;
    if (hour > 12) hour = hour % 12;
    return `
      ${this.props.kickoff.getMonth() + 1}.${this.props.kickoff.getDate()}
      ${hour}:${minutes}${amPm}
    `;
  }

  motM() {
    if (!this.state.canVoteForMotM) return '';
    if (this.props.motM) {
      return (
        <MotM
          match_id={this.props.id}
          kickoff={this.props.kickoff}
          self_url={this.motMUrl}
          match_url={this.selfUrl}
          exit={this.clearGame}
          {...this.props.motM}
        />
      );
    } else {
      let showMotM = (e) => {
        e.preventDefault();

        this.setState({ loading: true });
        this.props.getMotM()
          .done(() => {
            this.setState({ loading: false });
          });
      };
      return (
        <a href={this.motMUrl} onClick={showMotM}>RevGuess</a>
      );
    }
  }

  navigate(callback) {
    let pathname = document.location.pathname;
    if (pathname.indexOf(this.motMUrl) === 0 ||
      pathname.indexOf(this.revGuessUrl) === 0 ||
      pathname.indexOf(this.selfUrl) === 0
    ) {

    }
  }

  revGuess() {
    if (!this.state.canMakeRevGuess) return '';
    if (this.props.revGuess) {
      return (
        <RevGuess
          match_id={this.props.id}
          self_url={this.revGuessUrl}
          match_url={this.selfUrl}
          exit={this.clearGame}
        />
      );
    } else {
      let showRevGuess = (e) => {
        e.preventDefault();

        this.setState({ loading: true });
        this.props.getRevGuess()
          .done(() => {
            this.setState({ loading: false });
          });
      };
      return (
        <a href={this.revGuessUrl} onClick={showRevGuess}>RevGuess</a>
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
      <li className="match">
        <time dateTime={this.props.kickoff.toISOString()}>
          <a href={`/matches/${this.props.id}`}>
            {this.formatKickoff()}
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
  kickoff: React.PropTypes.instanceOf(Date),
  location: React.PropTypes.string,
  show_admin_ui: React.PropTypes.bool,
  getMotM: React.PropTypes.func,
  getRevGuess: React.PropTypes.func,
  clearGame: React.PropTypes.func,
  motM: React.PropTypes.object,
  revGuess: React.PropTypes.object
};
