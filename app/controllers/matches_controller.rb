# Controller for +Match+ model.
class MatchesController < ApplicationController
  load_and_authorize_resource
  require 'net/http'

  # GET /matches
  # GET /matches.json
  def index
    @start_date = (params[:date].try(:in_time_zone, Time.zone) || Time.current).beginning_of_week
    @matches = Match.unscoped.with_clubs.includes(:pick_ems).where(kickoff: (@start_date..@start_date + 7.days)).order(kickoff: :asc, location: :asc)
    @prev_link = "Previous #{'Game ' if @matches.empty?}Week"
    @next_link = "Next #{'Game ' if @matches.empty?}Week"
    @prev_date = (@matches.empty? ? Match.unscoped.where('kickoff < NOW()').order(kickoff: :asc).last.kickoff : @start_date - 1.week).to_date
    @next_date = (@matches.empty? ? Match.unscoped.where('kickoff > NOW()').order(kickoff: :asc).first.kickoff : @start_date + 1.week).to_date
  end

  # GET /matches/1
  # GET /matches/1.json
  def show
    @order_point = @match.order_selected(Match.all_seasons)
    @mot_m_players = Player.includes(:mot_m_firsts,:mot_m_seconds,:mot_m_thirds).select{|x| x.mot_m_total(match_id: @match.id) && x.mot_m_total(match_id: @match.id) > 0 }.sort_by{|x| x.mot_m_total(match_id: @match.id)}.reverse if @match.teams.include? revs
  end

  # TODO: Allow updated URLs and/or alternate sources

  # Imports matches from MLS Calendar.
  def import
    url = URI.parse(params[:url])
    begin
      req = Net::HTTP::Get.new(url.path)
      response = Net::HTTP.start(url.host, url.port){ |http| http.request(req) }
      if response.code_type.in? [ Net::HTTPRedirection, Net::HTTPFound ]
        response = Net::HTTP.get(URI(response['location']))
      else
        response = response.body
      end
    rescue SocketError => e
      logger.error "SocketError during Match import: #{e}"
      redirect_to matches_path, alert: e and return
    end
    cals = Icalendar.parse(response)
    cal = cals.first
    count = 0
    cal.events.each do |m|
      match = Match.where(uid: m.uid.to_s).first_or_initialize
      teams = m.summary.gsub(/\(.+?\)/,'').strip.split(/\s*vs\.?\s*/i).map{|t| t.gsub(/[\.\-]/,'').gsub(/(?<=\s|\A)(?!NYC)([A-Z]\.?){2,}(?=\s|\z)/,'').sub(/edbull/i, 'ed Bull')}
      match.location = m.location.to_s
      match.home_team = Club.where('replace(name,\'é\',\'e\') LIKE :name', name: "%#{teams[0]}%").first
      match.away_team = Club.where('replace(name,\'é\',\'e\') LIKE :name', name: "%#{teams[1]}%").first
      match.kickoff = m.dtstart.to_time
      match.season = match.kickoff.year
      count_it = match.new_record? || match.changed?
      puts teams
      if match.save!
        count += 1 if count_it
      else
        flash.alert ||= ''
        flash.alert += "\nCould not save #{m.summary}: #{match.errors.to_hash}"
        logger.error "Could not save #{m.summary}: #{match.errors.to_hash}"
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
        format.html { redirect_to matches_path(date: @match.kickoff.to_date), notice: 'Match was successfully updated.' }
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
      @match = Match.with_clubs.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def match_params
      params.require(:match).permit(:home_team_id, :away_team_id, :kickoff, :kickoff_date, :kickoff_time, :location, :home_goals, :away_goals)
    end
end
