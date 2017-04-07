# Controller for Man of the Match model, +MotM+.
class MotMsController < ApplicationController
  load_and_authorize_resource only: %i(index)
  before_action :check_eligible, only: %i(create)
  before_action :set_match, only: %i(show create)
  before_action :set_mot_m, only: %i(show create)
  skip_before_action :verify_authenticity_token, only: %i(create)

  # GET /mot_ms
  def index
    @mstart       = (params[:date].try(:to_datetime) || Date.current).beginning_of_month
    @season       = @mstart.year
    @months       = [*past_match_months, Date.current.beginning_of_month].uniq
    yr_matches    = revs.matches.unscope(where: :season).where(season: @mstart.year)
    @yr_match_ids = yr_matches.map(&:id)
    @mo_match_ids = yr_matches.where(kickoff: (@mstart..@mstart.end_of_month)).map(&:id)
    @mot_ms       = Player.includes(:mot_m_firsts, :mot_m_seconds, :mot_m_thirds).select { |x| x.mot_m_total(season: @season) > 0 }.sort_by(&:last_name)
    @mot_m_mo     = @mot_ms.group_by { |x| x.mot_m_total(match_id: @mo_match_ids) }.reject { |k, _v| k == 0 }.sort_by(&:first).reverse
    @mot_m_yr     = @mot_ms.group_by { |motm| motm.mot_m_total(season: @season) }.sort_by(&:first).reverse
    @mot_ms_for_mo = Player.mot_ms_for(Match.find(@mo_match_ids))
    @mot_ms_for_yr = Player.mot_ms_for(yr_matches)
  end

  def show
    render json: @mot_m, serializer: MotMSerializer, scope: view_context
  end

  # POST /mot_ms
  def create
    @mot_m.assign_attributes mot_m_params

    respond_to do |format|
      if @mot_m.save
        format.html { redirect_to matches_path(date: @match.kickoff.beginning_of_week), notice: 'Your vote was successfully cast.' }
        format.json { render json: @mot_m, serializer: MotMSerializer, scope: view_context, status: :created, location: @mot_m }
      else
        format.html {
          redirect_to matches_url(date: @match.kickoff.to_date),
            notice: 'There was an issue submitting your MotM vote: ' + @mot_m.errors.messages.to_sentence
        }
        format.json { render json: @mot_m.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Set +@match+ based on route's +:match_id+.
  def set_match
    @match = Match.unscope(where: :season).find(params[:match_id])
  end

  def set_mot_m
    @mot_m = @match.mot_ms.find_or_initialize_by(user_id: current_user.id)
  end

  # Redirects to matches path for that week if the match is not voteable
  def check_eligible
    authorize! :manage, MotM, match_id: @match.id
    redirect_to matches_path(date: @match.kickoff.to_date), flash: { notice: 'Cannot submit Man of the Match for that match.' } unless @match.voteable?
  end

  # Strong params for +MotM+.
  def mot_m_params
    params.require(:mot_m).permit(:first_id, :second_id, :third_id)
  end

  def past_match_months
    Match.unscoped
      .where('kickoff <= :time', time: Time.current)
      .pluck('DISTINCT cast(date_trunc(\'month\', kickoff) as date)')
      .sort
  end
end
