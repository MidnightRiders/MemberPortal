class MatchesController < ApplicationController
  before_action :set_match, only: [:show, :edit, :update, :destroy]

  # GET /matches
  # GET /matches.json
  def index
    @start_date = params[:date] ? params[:date].to_date : Date.today
    @start_date = @start_date.beginning_of_week
    @matches = Match.where('kickoff >= :start_date AND kickoff <= :end_date', start_date: @start_date, end_date: @start_date + 7.days).order('kickoff ASC')
  end

  # GET /matches/1
  # GET /matches/1.json
  def show
    @mot_ms = @match.mot_ms.sort(&:mot_m_total)
  end

  def import
    url = URI('https://r.e-c.al/ecal-sub/53187c3d7f4b3faf25000047/MLS+Calendar.ics')
    begin
      src = Net::HTTP.get(url)
    rescue SocketError => e
      redirect_to matches_path, alert: e and return
    end
    cals = Icalendar.parse(src)
    cal = cals.first
    count = 0
    cal.events.each do |m|
      match = Match.find_or_initialize_by(uid: m.uid)
      teams = m.summary.split(/\s*vs\s*/i)
      teams.map!{|t| t.gsub(/[\.\-]/,'').gsub(/\s*(FC|SC)\s*/i,'')}
      match.location = m.location
      match.home_team = Club.where('replace(name,\'é\',\'e\') LIKE :name', name: "%#{teams[0]}%").first
      match.away_team = Club.where('replace(name,\'é\',\'e\') LIKE :name', name: "%#{teams[1]}%").first
      match.kickoff = m.dtstart
      if match.save
        count += 1 if match.new_record? || match.changed?
      else
        flash.alert ||= ''
        flash.alert += "\nCould not save #{m.summary}: #{match.errors.to_hash}"
      end
    end
    flash[:success] = "#{count} Matches were saved or updated."
    redirect_to matches_path
  end

  # GET /matches/new
  def new
    @match = Match.new
  end

  # GET /matches/1/edit
  def edit
  end

  # POST /matches
  # POST /matches.json
  def create
    @match = Match.new(match_params)

    respond_to do |format|
      if @match.save
        format.html { redirect_to @match, notice: 'Match was successfully created.' }
        format.json { render action: 'show', status: :created, location: @match }
      else
        format.html { render action: 'new' }
        format.json { render json: @match.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /matches/1
  # PATCH/PUT /matches/1.json
  def update
    respond_to do |format|
      if @match.update(match_params)
        format.html { redirect_to @match, notice: 'Match was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @match.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /matches/1
  # DELETE /matches/1.json
  def destroy
    @match.destroy
    respond_to do |format|
      format.html { redirect_to matches_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_match
      @match = Match.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def match_params
      params.require(:match).permit(:home_team_id, :away_team_id, :kickoff, :location, :home_goals, :away_goals)
    end
end
