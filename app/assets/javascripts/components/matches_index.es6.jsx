class MatchesIndex extends React.Component {
  constructor(props) {
    super(props);

    this.state = this.stateFromProps(props);
  }

  stateFromProps(props) {
    return {
      startDate: new Date(props.startDate),
      prevWeek: props.prevWeek ? new Date(props.prevWeek) : null,
      nextWeek: props.nextWeek ? new Date(props.nextWeek) : null,
      matches: props.matches,
      loadingMatches: false
    };
  }

  adminButton() {
    if (!this.props.showAdminUi) return;
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
    window.onpopstate = this.navigate.bind(this);
  }

  componentWillUnmount() {
    window.onpopstate = null;
  }

  currentWeekLink() {
    if (this.state.startDate < new Date() && +new Date() < +this.state.startDate + 1000 * 60 * 60 * 24 * 7) return '\u00A0';
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
    return `${this.state.startDate.getMonth() + 1}.${this.state.startDate.getDate()}.${this.state.startDate.getFullYear()}`;
  }

  navigate() {
    this.setState({ loadingMatches: true });
    jQuery.ajax(document.location.href, { dataType: 'json' })
      .then((data) => this.setState(this.stateFromProps(data)));
  }

  navLink(which) {
    if (!this.state[`${which}Week`]) return '\u00A0';
    let title = `${which === 'prev' ? 'Previous' : 'Next'} Game Week`;
    return (
      <a
        href={`/matches?date=${this.yyyyMmDd(this.state[`${which}Week`])}`}
        onClick={this.anchorPushState.bind(this)}
        className={`matches-navigate matches-navigate-${which}`}
        title={title}
      />
    );
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
            showAdminUi={this.props.showAdminUi}
            loading={this.state.loadingMatches}
          />
        </div>
      </div>
    );
  }
}

MatchesIndex.propTypes = {
  showAdminUi: React.PropTypes.bool,
  startDate: React.PropTypes.number,
  prevWeek: React.PropTypes.number,
  nextWeek: React.PropTypes.number,
  matches: React.PropTypes.array
};
