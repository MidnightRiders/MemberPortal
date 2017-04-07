/*global React*/
class PickEm extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      hover: null,
      pick: props.pick,
      loading: false
    };

    ['handleClick', 'handleMouseEnter', 'handleMouseLeave'].forEach((e) => this[e] = this[e].bind(this));
  }

  result() {
    let hg = this.props.home_goals,
        ag = this.props.away_goals;
    if (this.props.home_goals === null || this.props.away_goals === null) return null;
    if (hg > ag) return 'home';
    if (ag > hg) return 'away';
    return 'draw';
  }

  score(side) {
    if (this.props.home_goals === null || this.props.away_goals === null) return;
    let team = this.props[`${side}_team`],
        goals = this.props[`${side}_goals`];
    return (
      <div className={`pick-em-result-score secondary-bg ${team.abbrv.toLowerCase()}`}>{goals}</div>
    );
  }

  title(side) {
    let text = side === 'draw' ? 'Draw' : this.props[`${side}_team`].name;
    if (this.state.pick === side) text += ' (Picked)';
    if (this.result() === side) text += ' (Result)';
    return text;
  }

  handleMouseEnter(event) {
    this.setState({ hover: event.currentTarget.dataset.pick });
  }

  handleMouseLeave() {
    this.setState({ hover: null });
  }

  handleClick(event) {
    event.preventDefault();
    if (this.state.past) return;
    let choice = event.currentTarget;
    this.setState({ loading: true });
    jQuery.ajax({
      url: choice.pathname,
      data: choice.search.replace(/^\?/, ''),
      method: 'post'
    }).always(() => {
      this.setState({
        loading: false
      });
    }).done(() => {
      this.setState({
        pick: choice.dataset.pick
      });
    });
  }

  containerClassNames() {
    let result = this.result();
    return [
      'pick-em-picker',
      this.state.hover && !this.state.pick && !this.state.past ? `hover-${this.state.hover}` : '',
      this.state.pick ? `picked-${this.state.pick}` : '',
      result ? `result-${result}` : '',
      this.props.past ? 'past' : '',
      this.state.loading ? 'loading' : ''
    ].filter((o) => !!o).join(' ');
  }

  render () {
    return (
      <div className={this.containerClassNames()}>
        <div className="pick-em-bar" />
        <a href={`/matches/${this.props.match_id}/pick_ems/vote?pick_em[result]=1`}
          data-pick="home"
          className={`home ${this.props.home_team.abbrv.toLowerCase()} primary-bg crest`}
          onMouseEnter={this.handleMouseEnter}
          onMouseLeave={this.handleMouseLeave}
          onClick={this.handleClick}
          title={this.title('home')}>
          <div className="value">{this.props.home_team.abbrv}</div>
          {this.score('home')}
        </a>
        <a href={`/matches/${this.props.match_id}/pick_ems/vote?pick_em[result]=0`}
          data-pick="draw"
          className="draw"
          onMouseEnter={this.handleMouseEnter}
          onMouseLeave={this.handleMouseLeave}
          onClick={this.handleClick}
          title={this.title('draw')}>
          <div className="value">Draw</div>
        </a>
        <a href={`/matches/${this.props.match_id}/pick_ems/vote?pick_em[result]=-1`}
          data-pick="away"
          className={`away ${this.props.away_team.abbrv.toLowerCase()} primary-bg crest`}
          onMouseEnter={this.handleMouseEnter}
          onMouseLeave={this.handleMouseLeave}
          onClick={this.handleClick}
          title={this.title('away')}>
          <div className="value">{this.props.away_team.abbrv}</div>
          {this.score('away')}
        </a>
      </div>
    );
  }
}

PickEm.propTypes = {
  match_id: React.PropTypes.number,
  home_team: React.PropTypes.object,
  away_team: React.PropTypes.object,
  home_goals: React.PropTypes.number,
  away_goals: React.PropTypes.number,
  pick: React.PropTypes.string,
  past: React.PropTypes.bool
};
