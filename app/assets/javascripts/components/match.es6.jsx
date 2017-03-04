/*global React, PickEm*/
class Match extends React.Component {
  formatKickoff() {
    let hour = this.props.kickoff.getHours(),
        minutes = `0${this.props.kickoff.getMinutes()}`.substr(-2),
        amPm = hour > 11 ? 'pm' : 'am';
    if (hour === 0) hour = 12;
    if (hour > 12) hour = hour % 12;
    return `
      ${this.props.kickoff.getMonth() + 1}.${this.props.kickoff.getDate()}
      ${hour}:${minutes}${amPm}`;
  }

  formatScore() {
    return `
      ${this.props.homeTeam.abbrv}
      ${this.props.homeGoals === null ? '' : this.props.homeGoals}
      -
      ${this.props.awayGoals === null ? '' : this.props.awayGoals }
      ${this.props.awayTeam.abbrv}
    `;
  }

  render () {
    return (
      <li className="match">
        <time dateTime={this.props.kickoff.toISOString()}>
          <a href={`/matches/${this.props.id}`}>
            {this.formatKickoff()}
            <i className="fa fa-arrow-circle-right fa-fw" />
          </a>
        </time>
        <div className="score">
          {this.formatScore()}
        </div>
        <div className="pick-em-container">
          <PickEm
            key={`pick-em-for-${this.props.id}`}
            matchId={this.props.id}
            homeTeam={this.props.homeTeam}
            awayTeam={this.props.awayTeam}
            homeGoals={this.props.homeGoals}
            awayGoals={this.props.awayGoals}
            pick={this.props.pick}
            kickoff={this.props.kickoff}
          />
        </div>
        <div className="location">
          {this.props.location}
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
  location: React.PropTypes.string
};
