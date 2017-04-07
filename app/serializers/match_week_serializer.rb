class MatchWeekSerializer < MatchesSerializer
  attributes :meta

  def meta
    {
      start_date: start_date,
      prev_week: prev_week,
      next_week: next_week,
      show_admin_ui: show_admin_ui,
      base_url: base_url
    }
  end

  def base_url
    if instance_options[:start_date] == Date.current.beginning_of_week
      scope.matches_path
    else
      scope.matches_path(date: instance_options[:start_date])
    end
  end

  def start_date
    instance_options[:start_date].to_f * 1000
  end

  def next_week
    next_match_week_from(instance_options[:start_date]).to_f * 1000
  end

  def prev_week
    previous_match_week_from(instance_options[:start_date]).to_f * 1000
  end

  def show_admin_ui
    scope.can? :manage, Match
  end

  private

  def next_match_week_from(date)
    Match.unscope(where: :season)
      .where('kickoff >= ?', date.beginning_of_week + 1.week)
      .reorder(kickoff: :asc)
      .limit(1)
      .pluck(:kickoff)
      .first
      &.beginning_of_week
  end

  def previous_match_week_from(date)
    Match.unscope(where: :season)
      .where('kickoff < ?', date.beginning_of_week)
      .reorder(kickoff: :desc)
      .limit(1)
      .pluck(:kickoff)
      .first
      &.beginning_of_week
  end
end
