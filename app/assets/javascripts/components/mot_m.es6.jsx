/* global React,MotM */
class MotM extends React.Component {
  constructor(props) {
    if (typeof props.kickoff === 'number') props.kickoff = new Date(props.kickoff);
    super(props);

    ['activate', 'deactivate'].forEach((func) => this[func] = this[func].bind(this));

    this.state = {
      active: false, // TODO: Inherit from initial page's state
      first_id: props.first_id,
      second_id: props.second_id,
      third_id: props.third_id
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
    history.pushState({}, '', this.props.motMUrl);
  }

  deactivate(e) {
    e.preventDefault();
    this.setState({ active: false });
  }

  button() {
    return (
      <a href={this.props.motMUrl} onClick={this.activate}>
        Man of the Match
      </a>
    );
  }

  form() {
    return (
      <form className="match-motm" action={this.props.motMUrl}>
        <a href={this.props.backLink} onClick={this.deactivate}>&times;</a>
        <h4>Man of the Match</h4>
        <input type="hidden" name="mot_m[match_id]" value={this.props.match_id} />
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
  match_id: React.PropTypes.number.isRequired,
  kickoff: React.PropTypes.oneOfType([React.PropTypes.instanceOf(Date), React.PropTypes.number]),
  first_id: React.PropTypes.number,
  second_id: React.PropTypes.number,
  third_id: React.PropTypes.number,
  self_url: React.PropTypes.string,
  match_url: React.PropTypes.string,
  navigate: React.PropTypes.func
};
