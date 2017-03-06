class MatchCollection extends React.Component {
  render () {
    if (this.props.matches.length) {
      return (
        <ul className="matches">
          {this.props.matches.map((match) => {
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
                showAdminUi={this.props.showAdminUi}
              />
            );
          })
          }
        </ul>
      );
    } else {
      return (
        <div className="alert alert-box">
          <h2 className="text-center">No matches scheduled this week.</h2>
        </div>
      );
    }
  }
}

MatchCollection.propTypes = {
  matches: React.PropTypes.array,
  showAdminUi: React.PropTypes.bool
};
