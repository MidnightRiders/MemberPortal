class MatchCollection extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      matches: props.matches,
      mot_m: props.mot_m || false,
      rev_guess: props.rev_guess || false
    };

    this.base_url = props.base_url;
    this.getRevGuessFor = this.getRevGuessFor.bind(this);
    this.getMotMFor = this.getMotMFor.bind(this);
    this.clearGame = this.clearGame.bind(this);
  }

  clearGame() {
    this.setState({ rev_guess: false, mot_m: false });
    history.pushState(this.state, null, this.base_url);
  }

  componentDidMount() {
    this.base_url = this.base_url || location.href.replace(location.hash, '');
    if (!history.state) {
      history.replaceState(this.state, null, this.base_url);
    }
  }

  getRevGuessFor(match) {
    return jQuery.getJSON(`/matches/${match.id}/rev_guess`)
      .done((data) => {
        this.setState({ rev_guess: data, mot_m: false });
        history.pushState(this.state, null, `/matches/${match.id}/rev_guess`);
      });
  }

  getMotMFor(match) {
    return jQuery.getJSON(`/matches/${match.id}/motm`)
      .done((data) => {
        this.setState({ rev_guess: false, mot_m: data });
        history.pushState(this.state, null, `/matches/${match.id}/motm`);
      });
  }

  matchList() {
    return this.state.matches.map((match) => {
      let motM = (this.state.mot_m && this.state.mot_m.match_id === match.id) ? this.state.mot_m : null;
      let revGuess = (this.state.rev_guess && this.state.rev_guess.match_id === match.id) ? this.state.rev_guess : null;

      return (
        <Match
          key={`match-${match.id}`}
          id={match.id}
          home_team={match.home_team}
          away_team={match.away_team}
          home_goals={match.home_goals}
          away_goals={match.away_goals}
          pick={match.pick}
          kickoff={new Date(match.kickoff)}
          location={match.location}
          show_admin_ui={this.props.show_admin_ui}
          getRevGuess={() => this.getRevGuessFor(match)}
          getMotM={() => this.getMotMFor(match)}
          clearGame={this.clearGame}
          motM={motM}
          revGuess={revGuess}
        />
      );
    });
  }

  render() {
    if (this.state.matches.length > 0) {
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
  mot_m: React.PropTypes.object,
  rev_guess: React.PropTypes.object,
  show_admin_ui: React.PropTypes.bool,
  loading: React.PropTypes.bool
};
