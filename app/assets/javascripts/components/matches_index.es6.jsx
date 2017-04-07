/* global React */
class MatchesIndex extends React.Component {
  constructor(props) {
    super(props);

    this.state = this.stateFromProps(props);
    this.navigate = this.navigate.bind(this);
  }

  adminButton() {
    if (!this.props.meta.show_admin_ui) return;
    return (
      <a href="#" className="button small expand" data-reveal-id="matches-admin">
        <i className="fa fa-bolt fa-fw"/>
        Admin
      </a>
    );
  }

  anchorPushState(e) {
    if (!window.history || !window.history.pushState) return;
    e.preventDefault();
    window.history.pushState({}, '', e.currentTarget.href);
    this.navigate();
  }

  componentDidMount() {
    let currentState = history.state || {};
    currentState.start_date = this.state.start_date;
    currentState.url = window.location.href;
    history.replaceState(currentState, '', window.location.href);
    jQuery(window).on('popstate', this.navigate);
  }

  componentWillUnmount() {
    jQuery(window).off('popstate', this.navigate);
  }

  currentWeekLink() {
    if (this.state.start_date < new Date() && +new Date() < +this.state.start_date + 1000 * 60 * 60 * 24 * 7) return '\u00A0';
    return (
      <a
        href="/matches"
        onClick={this.anchorPushState.bind(this)}
        className="matches-navigate matches-navigate-current"
        title="Current Week"
      />
    )
  }

  formatDate() {
    return `${this.state.start_date.getMonth() + 1}.${this.state.start_date.getDate()}.${this.state.start_date.getFullYear()}`;
  }

  navigate() {
    this.setState({ loadingMatches: true });
    jQuery.ajax(document.location.href, { dataType: 'json' })
      .then((data) => this.setState(this.stateFromProps(data)));
  }

  navLink(which) {
    if (!this.state[`${which}_week`]) return '\u00A0';
    let title = `${which === 'prev' ? 'Previous' : 'Next'} Game Week`;
    return (
      <a
        href={`/matches?date=${this.yyyyMmDd(this.state[`${which}_week`])}`}
        onClick={this.anchorPushState.bind(this)}
        className={`matches-navigate matches-navigate-${which}`}
        title={title}
      />
    );
  }

  stateFromProps(props) {
    return {
      loadingMatches: false,
      matches: props.matches,
      start_date: new Date(props.meta.start_date),
      prev_week: props.meta.prev_week ? new Date(props.meta.prev_week) : null,
      next_week: props.meta.next_week ? new Date(props.meta.next_week) : null
    };
  }

  yyyyMmDd(date) {
    return `${date.getFullYear()}-${`0${date.getMonth() + 1}`.substr(-2, 2)}-${`0${date.getDate()}`.substr(-2, 2)}`;
  }

  render() {
    return (
      <div className="row">
        <div className="medium-6 columns">
          <section className="card">
            {this.adminButton()}
            <h2>Matches for the week of {this.formatDate()}</h2>
            <div className="show-for-medium-up">
              <p>
                Make your <strong>Pick ’Em</strong> picks by clicking on the crest of the team you expect to win, or
                the dot in the center for a draw.
              </p>
              <p>
                To submit your <strong>RevGuess</strong>, click on the button underneath any Revs game before kickoff.
              </p>
              <p>
                And don’t forget to come back after every game to vote for your Man of the Match –
                voting for <strong>Man of the Match</strong> is tallied at the end of every year for the Riders’
                annual <a href="http://www.midnightriders.com/events-awards/man-of-the-year-award/">Man of the Year</a> award.
              </p>
            </div>
          </section>
        </div>
        <div className="medium-6 columns">
          <div className="row">
            <div className="small-4 columns">
              {this.navLink('prev')}
            </div>
            <div className="small-4 columns">
              {this.currentWeekLink()}
            </div>
            <div className="small-4 columns">
              {this.navLink('next')}
            </div>
          </div>
          <MatchCollection
            matches={this.state.matches}
            mot_m={this.props.mot_m}
            rev_guess={this.props.rev_guess}
            show_admin_ui={this.props.meta.show_admin_ui}
            loading={this.state.loadingMatches}
          />
        </div>
      </div>
    );
  }
}

MatchesIndex.propTypes = {
  meta: React.PropTypes.shape({
    show_admin_ui: React.PropTypes.bool,
    start_date: React.PropTypes.number.isRequired,
    prev_week: React.PropTypes.number,
    next_week: React.PropTypes.number
  }).isRequired,
  matches: React.PropTypes.array.isRequired,
  mot_m: React.PropTypes.object,
  rev_guess: React.PropTypes.object
};
