# Controller for Man of the Match model, +MotM+.
class MotMsController < ApplicationController
  load_and_authorize_resource
  before_action :set_match, except: [:index]
  before_action :check_eligible, only: %i(new edit create update)

  # GET /mot_ms
  # GET /mot_ms.json
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

  # GET /mot_ms/new
  def new
    redirect_to edit_match_mot_m_url(@match, @mot_m) if @mot_m = @match.mot_ms.find_by(user_id: @current_user)
    @mot_m = @match.mot_ms.new
  end

  # GET /mot_ms/1/edit
  def edit
  end

  # POST /mot_ms
  # POST /mot_ms.json
  def create
    @mot_m = MotM.new(mot_m_params)

    respond_to do |format|
      if @mot_m.save
        format.html { redirect_to matches_path, notice: 'Your vote was successfully cast.' }
        format.json { render action: 'show', status: :created, location: @mot_m }
      else
        format.html { render action: 'new' }
        format.json { render json: @mot_m.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mot_ms/1
  # PATCH/PUT /mot_ms/1.json
  def update
    respond_to do |format|
      if @mot_m.update(mot_m_params)
        format.html { redirect_to matches_path, notice: 'Your vote was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @mot_m.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mot_ms/1
  # DELETE /mot_ms/1.json
  def destroy
    @mot_m.destroy
    respond_to do |format|
      format.html { redirect_to matches_url }
      format.json { head :no_content }
    end
  end

  private

  # Set +@match+ based on route's +:match_id+.
  def set_match
    @match = Match.unscope(where: :season).find(params[:match_id])
  end

  # Redirects to matches path for that week if the match is not voteable
  def check_eligible
    redirect_to matches_path(date: @match.kickoff.to_date), flash: { notice: 'Cannot submit Man of the Match for that match.' } unless @match.voteable?
  end

  # Strong params for +MotM+.
  def mot_m_params
    params.require(:mot_m).permit(:user_id, :match_id, :first_id, :second_id, :third_id)
  end

  def past_match_months
    Match.unscoped
      .where('kickoff <= :time', time: Time.current)
      .pluck('DISTINCT cast(date_trunc(\'month\', kickoff) as date)')
      .sort
  end
end
