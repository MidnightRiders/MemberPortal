/* global React,MotM */
class MotM extends React.Component {
  constructor(props) {
    super(props);

    this.motMUrl = `/matches/${this.props.matchId}/motm`;
    this.backLink = `/matches?date=${props.kickoff.getFullYear()}` +
      `-${`0${props.kickoff.getMonth() + 1}`.substr(-2, 2)}` +
      `-${`0${props.kickoff.getDate()}`.substr(-2, 2)}`;

    ['activate', 'deactivate'].forEach((func) => this[func] = this[func].bind(this));

    this.state = {
      active: false, // TODO: Inherit from initial page's state
      firstId: props.firstId,
      secondId: props.secondId,
      thirdId: props.thirdId
    };
  }

  buildSelect(place) {
    let name = `mot_m[${place}_id]}`,
        id = name.replace(/[^a-z]+/i, '_').replace(/^_|_$/, ''),
        titleized = place.substr(0, 1).toUpperCase() + place.substr(1);

    return (
      <div className="row">
        <div className="small-4 columns">
          <label htmlFor={id}>
            {titleized} Place:
          </label>
        </div>
        <div className="small-8 columns">
          <select id={id} name={name}>
            <option value="">Select {titleized} Place</option>
          </select>
        </div>
      </div>
    );
  }

  activate(e) {
    e.preventDefault();
    this.setState({ active: true });
    history.pushState({}, '', this.motMUrl);
  }

  deactivate(e) {
    e.preventDefault();
    this.setState({ active: false });
  }

  button() {
    return (
      <a href={this.motMUrl} onClick={this.activate}>
        Man of the Match
      </a>
    );
  }

  form() {
    return (
      <form className="match-motm" action={this.motMUrl}>
        <a href={this.backLink} onClick={this.deactivate}>&times;</a>
        <h4>Man of the Match</h4>
        <input type="hidden" name="mot_m[match_id]" value={this.props.matchId} />
        {this.buildSelect('first')}
        {this.buildSelect('second')}
        {this.buildSelect('third')}
        <button type="submit">Submit</button>
      </form>
    );
  }

  render () {
    return this.state.active ? this.form() : this.button();
  }
}

MotM.propTypes = {
  matchId: React.PropTypes.number,
  kickoff: React.PropTypes.instanceOf(Date),
  firstId: React.PropTypes.number,
  secondId: React.PropTypes.number,
  thirdId: React.PropTypes.number
};
