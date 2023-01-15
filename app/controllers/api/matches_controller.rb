class Api::MatchesController < ApiController
  skip_before_action :authenticate_user!, only: %i[next_revs_match]

  def next_revs_match
    @match = revs&.next_match
    render 'show'
  end

  def show
    authorize! :read, Match

    @match = Match.find(params[:id])
  end

  # TODO: match filtering
  def index
    authorize! :read, Match

    @start_date = (params[:date]&.in_time_zone(Time.zone) || Time.current).beginning_of_week
    @matches = Match.unscoped.with_clubs.includes(:pick_ems).where(kickoff: (@start_date..@start_date + 7.days)).order(kickoff: :asc, location: :asc)
    @prev_link = "Previous #{'Game ' if @matches.empty?}Week"
    @next_link = "Next #{'Game ' if @matches.empty?}Week"
    @prev_date = @matches.empty? ? Match.unscoped.where('kickoff < ?', Time.current).order(kickoff: :asc).last&.kickoff : @start_date - 1.week
    @prev_date = @prev_date&.to_date
    @next_date = @matches.empty? ? Match.unscoped.where('kickoff > ?', Time.current).order(kickoff: :asc).first&.kickoff : @start_date + 1.week
    @next_date = @next_date&.to_date
    @is_current_week = @start_date == Time.current.beginning_of_week
  end
end
