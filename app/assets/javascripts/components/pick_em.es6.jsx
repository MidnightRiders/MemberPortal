/*global React*/
class PickEm extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      hover: null,
      pick: props.pick,
      loading: false,
      disabled: props.kickoff < new Date()
    };

    this.kickoffInterval = null;

    ['handleClick', 'handleMouseEnter', 'handleMouseLeave'].forEach((e) => this[e] = this[e].bind(this));
  }

  result() {
    let hg = this.props.homeGoals,
        ag = this.props.awayGoals;
    if (this.props.homeGoals === null || this.props.awayGoals === null) return null;
    if (hg > ag) return 'home';
    if (ag > hg) return 'away';
    return 'draw';
  }

  score(side) {
    if (this.props.homeGoals === null || this.props.awayGoals === null) return;
    let team = this.props[`${side}Team`],
        goals = this.props[`${side}Goals`];
    return (
      <div className={`pick-em-result-score secondary-bg ${team.abbrv.toLowerCase()}`}>{goals}</div>
    );
  }

  handleMouseEnter(event) {
    this.setState({ hover: event.currentTarget.dataset.pick });
  }

  handleMouseLeave() {
    this.setState({ hover: null });
  }

  componentDidMount() {
    this.waitForKickoff();
  }

  componentWillUnmount() {
    this.stopWaitingForKickoff();
  }

  waitForKickoff() {
    if (!this.state.disabled && !this.kickoffInterval) {
      this.kickoffInterval = setInterval(() => {
        if (this.props.kickoff < new Date()) {
          this.setState({ disabled: true });
          this.stopWaitingForKickoff();
        }
      }, 5000);
    }
  }

  handleClick(event) {
    event.preventDefault();
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

  stopWaitingForKickoff() {
    if (this.kickoffInterval) {
      clearInterval(this.kickoffInterval);
      this.kickoffInterval = null;
    }
  }

  containerClassNames() {
    return [
      'pick-em-picker',
      this.state.hover ? `hover-${this.state.hover}` : '',
      this.state.pick ? `picked-${this.state.pick}` : '',
      this.result() ? `result-${this.result()}` : '',
      this.state.disabled ? 'disabled' : '',
      this.state.loading ? 'loading' : ''
    ].filter((o) => !!o).join(' ');
  }

  render () {
    return (
      <div className={this.containerClassNames()}>
        <a href={`/matches/${this.props.matchId}/pick_ems/vote?pick_em[result]=1`}
          data-pick="home"
          className={`home ${this.props.homeTeam.abbrv.toLowerCase()} primary-bg crest`}
          onMouseEnter={this.handleMouseEnter}
          onMouseLeave={this.handleMouseLeave}
          onClick={this.handleClick}
           title={this.props.homeTeam.name}>
          <div className="value">{this.props.homeTeam.abbrv}</div>
          {this.score('home')}
        </a>
        <a href={`/matches/${this.props.matchId}/pick_ems/vote?pick_em[result]=0`}
          data-pick="draw"
          className="draw"
          onMouseEnter={this.handleMouseEnter}
          onMouseLeave={this.handleMouseLeave}
          onClick={this.handleClick}
          title="Draw">
          <div className="value">Draw</div>
        </a>
        <a href={`/matches/${this.props.matchId}/pick_ems/vote?pick_em[result]=-1`}
          data-pick="away"
          className={`away ${this.props.awayTeam.abbrv.toLowerCase()} primary-bg crest`}
          onMouseEnter={this.handleMouseEnter}
          onMouseLeave={this.handleMouseLeave}
          onClick={this.handleClick}
          title={this.props.awayTeam.name}>
          <div className="value">{this.props.awayTeam.abbrv}</div>
          {this.score('away')}
        </a>
      </div>
    );
  }
}

PickEm.propTypes = {
  matchId: React.PropTypes.number,
  homeTeam: React.PropTypes.object,
  awayTeam: React.PropTypes.object,
  homeGoals: React.PropTypes.number,
  awayGoals: React.PropTypes.number,
  pick: React.PropTypes.string,
  kickoff: React.PropTypes.instanceOf(Date)
};
