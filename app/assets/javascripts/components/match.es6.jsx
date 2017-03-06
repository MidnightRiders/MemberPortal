/*global React, PickEm*/
class Match extends React.Component {
  constructor(props) {
    super(props);

    this.kickoffInterval = null;

    this.state = {
      canVoteForMotM: this.canVoteForMotM(),
      past: props.kickoff < new Date()
    };
  }

  formatKickoff() {
    let hour    = this.props.kickoff.getHours(),
        minutes = `0${this.props.kickoff.getMinutes()}`.substr(-2),
        amPm    = hour > 11 ? 'pm' : 'am';
    if (hour === 0) hour = 12;
    if (hour > 12) hour = hour % 12;
    return `
      ${this.props.kickoff.getMonth() + 1}.${this.props.kickoff.getDate()}
      ${hour}:${minutes}${amPm}`;
  }

  isRevs() {
    return this.props.homeTeam.abbrv === 'NE' || this.props.awayTeam.abbrv === 'NE';
  }

  canVoteForMotM() {
    return this.isRevs() &&
      this.props.kickoff < new Date() - 1000 * 60 * 45 &&         // at least 45 minutes ago
      this.props.kickoff > new Date() - 1000 * 60 * 60 * 24 * 14; // less than two weeks ago
  }

  componentDidMount() {
    this.waitForGameProgress();
  }

  componentWillUnmount() {
    this.stopWaitingForGameProgress();
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
          if (!this.isRevs()) this.stopWaitingForGameProgress();
        }
        if (this.state.past && this.isRevs() && this.canVoteForMotM()) {
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
            matchId={this.props.id}
            homeTeam={this.props.homeTeam}
            awayTeam={this.props.awayTeam}
            homeGoals={this.props.homeGoals}
            awayGoals={this.props.awayGoals}
            pick={this.props.pick}
            past={this.state.past}
          />
        </div>
      </li>
    );
  }
}

Match.propTypes = {
  id: React.PropTypes.number,
  homeTeam: React.PropTypes.object,
  awayTeam: React.PropTypes.object,
  homeGoals: React.PropTypes.number,
  awayGoals: React.PropTypes.number,
  pick: React.PropTypes.string,
  kickoff: React.PropTypes.instanceOf(Date),
  location: React.PropTypes.string,
  showAdminUi: React.PropTypes.bool
};
