class MotMsController < ApplicationController
  load_and_authorize_resource
  before_filter :set_match, except: [ :index ]

  # GET /mot_ms
  # GET /mot_ms.json
  def index
    @months = Match.where('kickoff <= ?', Time.now).group_by{|x| x.kickoff.beginning_of_month }.sort.map(&:first)
    @mstart = params[:date].try(:to_datetime) || Date.today.beginning_of_month
    month_matches = @revs.matches.where(kickoff: (@mstart...@mstart.end_of_month))
    @match_ids = month_matches.map(&:id)
    @mot_ms   = Player.includes(:motm_firsts,:motm_seconds,:motm_thirds).select{|x| x.mot_m_total > 0 }.sort_by(&:last_name)
    @mot_m_mo = @mot_ms.select{|x| x.mot_m_total(@match_ids) > 0 }.group_by{|x| x.mot_m_total(@match_ids) }.sort_by(&:first).reverse
    @mot_m_yr = @mot_ms.group_by(&:mot_m_total).sort_by(&:first).reverse
  end

  # GET /mot_ms/1
  # GET /mot_ms/1.json
  # def show
  #   respond_to do |format|
  #     format.html { redirect_to matches_path }
  #     format.json
  #   end
  # end

  # GET /mot_ms/new
  def new
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
    def set_match
      @match = Match.find(params[:match_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mot_m_params
      params.require(:mot_m).permit(:user_id, :match_id, :first_id, :second_id, :third_id)
    end
end
