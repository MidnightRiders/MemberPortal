class Matches extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      startDate: new Date(props.startDate)
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

  formatDate() {
    return `${this.state.startDate.getMonth() + 1}.${this.state.startDate.getDate()}.${this.state.startDate.getFullYear()}`;
  }

  render() {
    return (
      <div className="row">
        <div className="medium-4 large-6 columns">
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
        </div>
        <div className="medium-8 large-6 columns">
          <MatchCollection
            matches={this.props.matches}
            showAdminUi={this.props.showAdminUi}
          />
        </div>
      </div>
    );
  }
}

Matches.propTypes = {
  showAdminUi: React.PropTypes.bool,
  startDate: React.PropTypes.number,
  matches: React.PropTypes.array
};
