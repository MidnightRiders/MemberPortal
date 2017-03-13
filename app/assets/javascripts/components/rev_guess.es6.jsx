class RevGuess extends React.Component {
  render () {
    return (
      <div>
        <div>Match: {this.props.matchId}</div>
        <div>Home Goals: {this.props.homeGoals}</div>
        <div>Away Goals: {this.props.awayGoals}</div>
      </div>
    );
  }
}

RevGuess.propTypes = {
  matchId: React.PropTypes.number,
  homeGoals: React.PropTypes.number,
  awayGoals: React.PropTypes.number
};
