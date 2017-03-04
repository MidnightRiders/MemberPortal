/*global React, Match*/
class MatchesList extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      matches: props.matches
    };
  }
  renderMatches() {
    return this.state.matches.map((match) => {
      return (
        <Match
          key={`match-${match.id}`}
          id={match.id}
          homeTeam={match.homeTeam}
          awayTeam={match.awayTeam}
          homeGoals={match.homeGoals}
          awayGoals={match.awayGoals}
          pick={match.pick}
          kickoff={new Date(match.kickoff)}
          location={match.location}
        />
      );
    });
  }
  render () {
    return (
      <ul className="matches">
        {this.renderMatches()}
      </ul>
    );
  }
}

MatchesList.propTypes = {
  matches: React.PropTypes.array
};

