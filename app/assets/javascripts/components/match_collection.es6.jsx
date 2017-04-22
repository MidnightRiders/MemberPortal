/* global React */
class MatchCollection extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      matches: props.matches,
      mot_m: props.mot_m,
      rev_guess: props.rev_guess
    };

    ['baseUrl', 'clearGame', 'getRevGuessFor', 'getMotMFor', 'navigate', 'updateMatch']
      .forEach((method) => this[method] = this[method].bind(this));
  }

  baseUrl() {
    return '/home';
  }

  componentDidMount() {
    if (!history.state) history.replaceState(this.state, document.title, location.href);
    jQuery(window).on('popstate', this.navigate);
  }

  componentWillUnmount() {
    jQuery(window).off('popstate', this.navigate);
  }

  clearGame(e) {
    if (e) e.preventDefault();
    this.setState({ rev_guess: null, mot_m: null }, () => {
      history.pushState(this.state, 'Midnight Riders | Match Listings', this.baseUrl());
    });
  }

  getRevGuessFor(match) {
    return jQuery.getJSON(`/matches/${match.id}/rev_guess`)
      .done((data) => {
        this.setState({ rev_guess: data, mot_m: null }, () => {
          history.pushState(this.state, 'Midnight Riders | RevGuess', `/matches/${match.id}/rev_guess`);
        });
      })
      .error((err) => { /* noop */ });
  }

  getMotMFor(match) {
    return jQuery.getJSON(`/matches/${match.id}/motm`)
      .done((data) => {
        this.setState({ rev_guess: null, mot_m: data }, () => {
          history.pushState(this.state, 'Midnight Riders | Man of the Match', `/matches/${match.id}/motm`);
        });
      })
      .error((err) => { /* noop */ });
  }

  motMIfForMatch(match) {
    if (this.state.mot_m && this.state.mot_m.match_id === match.id) return this.state.mot_m;
  }

  revGuessIfForMatch(match) {
    if (this.state.rev_guess && this.state.rev_guess.match_id === match.id) return this.state.rev_guess;
  }

  matchList() {
    return this.state.matches.map((match) => {
      return (
        <Match
          key={`match-${match.id}`}
          {...match}
          kickoff={new Date(match.kickoff)}
          getRevGuess={() => this.getRevGuessFor(match)}
          getMotM={() => this.getMotMFor(match)}
          clearGame={this.clearGame}
          updateMatch={(state) => this.updateMatch(match, state)}
          motMForDisplay={this.motMIfForMatch(match)}
          revGuessForDisplay={this.revGuessIfForMatch(match)}
          baseUrl={this.baseUrl()}
        />
      );
    });
  }

  navigate() {
    console.log('navigated', history.state);
    if (history.state) this.setState(history.state);
  }

  updateMatch(match, state, title, url) {
    let deferred = jQuery.Deferred();
    Object.keys(state).forEach((key) => { match[key] = state[key]; });
    this.forceUpdate(deferred.resolve);
    return deferred;
  }

  render() {
    return (
      <ul className={`matches ${this.state.loadingMatches ? 'loading' : ''}`}>
        {this.matchList()}
      </ul>
    );
  }
}

MatchCollection.propTypes = {
  matches: React.PropTypes.array,
  mot_m: React.PropTypes.object,
  rev_guess: React.PropTypes.object,
  show_admin_ui: React.PropTypes.bool,
  loading: React.PropTypes.bool
};
