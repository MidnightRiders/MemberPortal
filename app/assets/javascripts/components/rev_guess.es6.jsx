/* global React,RevGuess */
class RevGuess extends React.Component {
  render () {
    return (
      <div>
        <div>Match: {this.props.match_id}</div>
        <div>Home Goals: {this.props.home_goals}</div>
        <div>Away Goals: {this.props.away_goals}</div>
      </div>
    );
  }
}

RevGuess.propTypes = {
  match_id: React.PropTypes.number.isRequired,
  home_goals: React.PropTypes.number,
  away_goals: React.PropTypes.number,
  self_url: React.PropTypes.string,
  match_url: React.PropTypes.string,
  navigate: React.PropTypes.func
};
