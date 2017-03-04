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

  hoverClassName() {
    if (!this.state.hover || this.state.pick) return '';
    return `hover-${this.state.hover}`;
  }

  // resultClassName() {
  //   let result = this.result();
  //   if (!result) return '';
  //   return `result-${result}`;
  // }

  pickedClassName() {
    if (!this.state.pick) return '';
    return `picked-${this.state.pick}`;
  }

  disabledClassName() {
    if (this.state.disabled || this.state.loading) return 'disabled';
    else return '';
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
    new Promise((resolve, reject) => {
      jQuery.ajax({
        data: choice.search.replace(/^\?/, ''),
        method: 'post',
        url: choice.pathname,
        success: resolve,
        error: reject
      })
    }).then(() => {
      this.setState({
        pick: choice.dataset.pick,
        loading: false
      });
    }).catch((e) => {
      this.setState({
        loading: false
      });
    });
  }

  stopWaitingForKickoff() {
    if (this.kickoffInterval) {
      clearInterval(this.kickoffInterval);
      this.kickoffInterval = null;
    }
  }

  render () {
    return (
      <div className={`pick-em-picker ${this.hoverClassName()} ${this.pickedClassName()} ${this.disabledClassName()}`}>
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
