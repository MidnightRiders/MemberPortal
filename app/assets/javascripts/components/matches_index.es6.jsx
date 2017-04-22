/* global React */
class MatchesIndex extends MatchCollection {
  constructor(props) {
    super(props);

    this.state.loadingMatches = false;
    this.state.meta = props.meta;

    ['adminButton', 'currentWeekLink', 'getMatches',
      'navLink', 'renderCollection', 'urlFor']
      .forEach((method) => this[method] = this[method].bind(this));
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

  baseUrl() {
    return this.urlFor(this.state.meta.start_date);
  }

  currentWeekLink() {
    if (moment(new Date()).isBetween(this.state.meta.start_date, this.state.meta.start_date + 1000 * 60 * 60 * 24 * 7)) return '\u00A0';
    return (
      <a
        href="/matches"
        onClick={this.getMatches}
        className="matches-navigate matches-navigate-current"
        title="Current Week"
      />
    )
  }

  getMatches(e) {
    e.preventDefault();
    let matchesUrl = e.currentTarget.href;
    this.setState({ loadingMatches: true });
    jQuery.getJSON(matchesUrl)
      .done((data) => {
        data.loadingMatches = false;
        this.setState(data, () => {
          history.pushState(this.state, 'Midnight Riders | Match Listings', matchesUrl);
        });
      });
  }

  urlFor(date) {
    if (moment(date).isSame(new Date(), 'week')) {
      return '/matches';
    } else {
      return `/matches?date=${moment(date).format('YYYY-MM-DD')}`;
    }
  }

  navLink(which) {
    if (!this.state.meta[`${which}_week`]) return '\u00A0';
    let title = `${which === 'prev' ? 'Previous' : 'Next'} Game Week`;
    return (
      <a
        href={this.urlFor(this.state.meta[`${which}_week`])}
        onClick={this.getMatches}
        className={`matches-navigate matches-navigate-${which}`}
        title={title}
      />
    );
  }

  renderCollection(sup) {
    if (this.state.matches.length > 0) {
      return sup();
    } else {
      return (
        <div className={`alert-box no-matches ${this.state.loadingMatches ? 'loading' : ''}`}>
          <h2 className="text-center">No matches scheduled this week.</h2>
        </div>
      );
    }
  }

  render() {
    return (
      <div className="row">
        <div className="medium-6 columns">
          <nav className="row matches-navigation">
            <div className="small-4 columns">
              {this.navLink('prev')}
            </div>
            <div className="small-4 columns">
              {this.currentWeekLink()}
            </div>
            <div className="small-4 columns">
              {this.navLink('next')}
            </div>
          </nav>
          <section className="card">
            <h2>Matches for the week of {moment(this.state.meta.start_date).format('M.D.YYYY')}</h2>
            <small className="show-for-small-only text-center">
              <em>Tap team or center dot to submit Pick ’Em</em><br />
              <i className="fa fa-balance-scale" /> <em>RevGuess</em> • <i className="fa fa-trophy" /> <em>Man of the Match</em>
            </small>
            <div className="show-for-medium-up">
              <p>
                Make your <strong>Pick ’Em</strong> picks by clicking on the crest of the team you expect to win, or
                the dot in the center for a draw.
              </p>
              <p>
                To submit your <strong>RevGuess</strong>, click on the <i className="fa fa-balance-scale" /> button underneath any Revs
                game before kickoff and submit your guess for the final result.
              </p>
              <p>
                And don’t forget to come back after every game to vote for your <i className="fa fa-trophy" /> <strong>Man of the Match</strong> –
                voting for Man of the Match is tallied at the end of every year for the Riders’
                annual <a href="http://www.midnightriders.com/events-awards/man-of-the-year-award/">Man of the Year</a> award.
              </p>
            </div>
          </section>
          {this.adminButton()}
        </div>
        <div className="medium-6 columns">
          {this.renderCollection(super.render.bind(this))}
        </div>
      </div>
    );
  }
}

let propTypes = Object.keys(MatchCollection.propTypes).reduce((obj, key) => {
  obj[key] = MatchCollection.propTypes[key];
  return obj;
}, {});

propTypes.meta = React.PropTypes.shape({
  show_admin_ui: React.PropTypes.bool,
  start_date: React.PropTypes.number.isRequired,
  prev_week: React.PropTypes.number,
  next_week: React.PropTypes.number
}).isRequired;

MatchesIndex.propTypes = propTypes;
