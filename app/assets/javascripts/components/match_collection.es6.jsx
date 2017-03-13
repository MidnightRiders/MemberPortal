class MatchCollection extends React.Component {
  matchList() {
    return this.props.matches.map((match) => {
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
    });
  }

  render() {
    if (this.props.matches.length > 0) {
      return (
        <ul className={`matches ${this.props.loading ? 'loading' : ''}`}>
          {this.matchList()}
        </ul>
      );
    } else {
      return (
        <div className={`alert-box no-matches ${this.props.loading ? 'loading' : ''}`}>
          <h2 className="text-center">No matches scheduled this week.</h2>
        </div>
      );
    }
  }
}

MatchCollection.propTypes = {
  matches: React.PropTypes.array,
  showAdminUi: React.PropTypes.bool,
  loading: React.PropTypes.bool
};
