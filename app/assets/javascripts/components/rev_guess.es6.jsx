/* global React,RevGuess */
class RevGuess extends React.Component {
  constructor(props) {
    super(props);

    this.state = { loading: false };
  }

  handleSubmit(e) {
    let form = e.currentTarget,
        homeGoals = form['rev_guess[home_goals]'].value,
        awayGoals = form['rev_guess[away_goals]'].value,
        homeGoalsNum = parseInt(homeGoals, 10),
        awayGoalsNum = parseInt(awayGoals, 10);
    if (isNaN(homeGoals) || isNaN(awayGoals) || homeGoals != homeGoalsNum || awayGoals != awayGoalsNum) {
      alert('Please enter real numbers.');
      return false;
    } else if (homeGoalsNum < 0 || homeGoalsNum > 10 || awayGoalsNum < 0 || awayGoalsNum > 10) {
      alert('Please enter a legitimate score');
      return false;
    }
    return true;
  }

  render () {
    return (
      <form className={`match-rev-guess ${this.state.loading ? 'loading' : ''}`} method="post" action={this.props.links.self} onSubmit={this.handleSubmit}>
        <a href={this.props.baseUrl} onClick={this.props.exitHandler} className="close">&times;</a>
        <h4>RevGuess: {this.props.home_team.abbrv} v {this.props.away_team.abbrv}</h4>
        <div className="row collapse">
          <div className="small-3 columns">
            <label htmlFor="rev_guess_home_goals" className={`prefix secondary-border primary-bg ${this.props.home_team.abbrv.toLowerCase()}`}>{this.props.home_team.abbrv}</label>
          </div>
          <div className="small-3 columns">
            <input type="number" className="text-center" name="rev_guess[home_goals]" id="rev_guess_home_goals" defaultValue={this.props.home_goals || 0} min={0} max={10} />
          </div>
          <div className="small-3 columns">
            <input type="number" className="text-center" name="rev_guess[away_goals]" id="rev_guess_away_goals" defaultValue={this.props.away_goals || 0} min={0} max={10} />
          </div>
          <div className="small-3 columns">
            <label htmlFor="rev_guess_away_goals" className={`postfix secondary-border primary-bg ${this.props.away_team.abbrv.toLowerCase()}`}>{this.props.away_team.abbrv}</label>
          </div>
        </div>
        <div className="row">
          <div className="column">
            <label for="rev_guess_comment">Comments:</label>
            <textarea id="rev_guess_comment" name="rev_guess[comment]" defaultValue={this.props.comment} />
          </div>
        </div>
        <div className="row">
          <div className="column">
            <button type="submit" className="expand no-margin-bottom"><i className="fa fa-balance-scale fa-fw" /> Submit RevGuess</button>
          </div>
        </div>
      </form>
    );
  }
}

RevGuess.propTypes = {
  exitHandler: React.PropTypes.func.isRequired,
  baseUrl: React.PropTypes.string.isRequired,
  updateMatch: React.PropTypes.func.isRequired,
  home_team: React.PropTypes.object.isRequired,
  away_team: React.PropTypes.object.isRequired,
  match_id: React.PropTypes.number.isRequired,
  links: React.PropTypes.object.isRequired,
  home_goals: React.PropTypes.number,
  away_goals: React.PropTypes.number,
  comment: React.PropTypes.string
};
