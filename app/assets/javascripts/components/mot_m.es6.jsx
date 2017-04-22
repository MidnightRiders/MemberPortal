/* global React,MotM */
class MotM extends React.Component {
  constructor(props) {
    super(props);

    this.state = { loading: false };

    ['buildSelect', 'handleSubmit'].forEach((method) => this[method] = this[method].bind(this));
    this.options = this.buildOptions();
  }

  buildOptions() {
    let grouped = this.props.players.reduce((obj, player) => {
      (obj[player.position] = obj[player.position] || []).push(player);
      return obj;
    }, {});
    return Object.keys(grouped).reverse().map((group) => {
      return (
        <optgroup label={group} key={group}>
          {grouped[group].map((player) => {
            return (
              <option value={player.id} key={player.id}>
                {player.number} - {player.first_name} {player.last_name}
              </option>
            );
          })}
        </optgroup>
      );
    });
  }

  buildSelect(place) {
    let name = `mot_m[${place}_id]`,
        id = name.replace(/[^a-z]+/i, '_').replace(/^_|_$/, ''),
        titleized = place.substr(0, 1).toUpperCase() + place.substr(1);

    return (
      <div className="row">
        <div className="show-for-medium-up medium-4 columns">
          <label htmlFor={id}>
            {titleized} Place:
          </label>
        </div>
        <div className="medium-8 columns">
          <select id={id} name={name} defaultValue={this.props[`${place}_id`] || ''}>
            <option value="">Select {titleized} Place</option>
            {this.options}
          </select>
        </div>
      </div>
    );
  }

  handleSubmit(e) {
    e.preventDefault();
    let form = e.currentTarget;

    this.setState({ loading: true });
    if (!this.formIsValid(form)) return;
    jQuery.post(form.action, jQuery(form).serialize())
      .then((data) => {
        return this.props.updateMatch({ mot_m: data });
      })
      .done(() => {
        console.log('successfully updated state');
        this.props.exitHandler();
      })
  }

  formIsValid(form) {
    let $selects = jQuery(form).find('select'),
        values = $selects.map((i, el) => el.value).get(),
        nonNullValues = values.filter((el) => !!el),
        nonNullUniqueValues = jQuery.unique(jQuery.extend([],nonNullValues)),
        dedupedValues = jQuery.extend([], nonNullUniqueValues);
    while (dedupedValues.length !== values.length) dedupedValues.push('');
    if (nonNullValues.length === 0) { // No selections
      alert('Please select at least one Man of the Match');
      return false;
    } else if (values.join(',') === dedupedValues.join(',')) { // Sequential pics, unique
      return true;
    } else if (nonNullValues.join(',') === nonNullUniqueValues.join(',')) { // Non-sequential picks, unique
      $selects.each((i, el) => { el.value = dedupedValues[i]; });
      alert('Please confirm your picks');
      return false;
    } else if (nonNullValues.length > nonNullUniqueValues.length) { // Duplicate values
      alert('You can\'t vote for the same player twice! Try again.');
      return false;
    }
  }

  render() {
    return (
      <form className={`match-motm ${this.state.loading ? 'loading' : ''}`} method="post" action={this.props.links.self} onSubmit={this.handleSubmit}>
        <a href={this.props.baseUrl} onClick={this.props.exitHandler} className="close">&times;</a>
        <h4>Man of the Match: {this.props.matchup}</h4>
        {this.buildSelect('first')}
        {this.buildSelect('second')}
        {this.buildSelect('third')}
        <div className="row">
          <div className="medium-8 medium-offset-4 columns">
            <button type="submit" className="expand no-margin-bottom"><i className="fa fa-trophy fa-fw" /></button>
          </div>
        </div>
      </form>
    );
  }
}

MotM.propTypes = {
  first_id: React.PropTypes.number,
  second_id: React.PropTypes.number,
  third_id: React.PropTypes.number,
  baseUrl: React.PropTypes.string.isRequired,
  links: React.PropTypes.object.isRequired,
  matchup: React.PropTypes.string.isRequired,
  players: React.PropTypes.array.isRequired,
  updateMatch: React.PropTypes.func.isRequired,
  exitHandler: React.PropTypes.func.isRequired
};
