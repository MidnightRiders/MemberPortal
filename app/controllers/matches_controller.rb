require 'net/http'

# Controller for +Match+ model.
class MatchesController < ApplicationController
  authorize_resource
  before_action :set_match, only: %i(show edit update destroy)
  before_action :check_for_matches_to_update, only: %i(auto_update)

  # GET /matches
  # GET /matches.json
  # GET /matches.svg
  # WIP: GET /matches.png
  def index
    @start_date = (params[:date].try(:in_time_zone, Time.zone) || Time.current).beginning_of_week
    @matches = Match.unscoped.with_clubs.includes(:pick_ems).where(kickoff: (@start_date..@start_date + 7.days)).order(kickoff: :asc, location: :asc)
    @prev_link = "Previous #{'Game ' if @matches.empty?}Week"
    @next_link = "Next #{'Game ' if @matches.empty?}Week"
    @prev_date = @matches.empty? ? Match.unscoped.where('kickoff < ?', Time.current).order(kickoff: :asc).last.try(:kickoff) : @start_date - 1.week
    @prev_date = @prev_date.try(:to_date)
    @next_date = @matches.empty? ? Match.unscoped.where('kickoff > ?', Time.current).order(kickoff: :asc).first.try(:kickoff) : @start_date + 1.week
    @next_date = @next_date.try(:to_date)
    @is_current_week = @start_date == Time.current.beginning_of_week
    respond_to do |format|
      format.html
      format.json
      format.svg {
        redirect_to matches_url unless current_user.privilege? 'admin'
        render layout: false, cached: false
      }
      # WIP: easily-reusable PNG generation from SVG
      # format.png {
      #   @embed_resources = true
      #   redirect_to matches_url unless current_user.privilege? 'admin'
      #   svg_str = render_to_string 'matches/index', layout: false, formats: %w[svg]
      #   img = Magick::Image.from_blob(svg_str) {
      #     self.background_color = '#6a0003'
      #     self.density= '144.0x144.0'
      #     self.format = 'SVG'
      #   }
      #   png = img[0].to_blob {
      #     self.density= '144.0x144.0'
      #     self.format = 'PNG'
      #   }
      #   send_data png, filename: "matches-#{@start_date.strftime('%Y-%m-%d')}.png", disposition: 'inline', type: 'image/png'
      # }
    end
  end

  # GET /matches/1
  # GET /matches/1.json
  def show
    @order_point = @match.order_selected(Match.all_seasons)
    @mot_m_players = Player.includes(:mot_m_firsts, :mot_m_seconds, :mot_m_thirds).select { |x| x.mot_m_total(match_id: @match.id) && x.mot_m_total(match_id: @match.id) > 0 }.sort_by { |x| x.mot_m_total(match_id: @match.id) }.reverse if @match.teams.include? revs
  end

  # GET /matches/sync
  def sync
    year = Date.current > Date.current.end_of_year - 15.days ? Date.current.year + 1 : Date.current.year
    uri = URI.parse("https://v3.football.api-sports.io/fixtures?league=253&season=#{year}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri)
    request['x-apisports-key'] = ENV['API_FOOTBALL_KEY']
    resp = http.request(request)

    match_data = JSON.parse(resp.read_body, symbolize_names: true)[:response]
    clubs = Club.all.map { |c| [c.api_id, c] }.to_h
    errors = []
    changed = 0
    added = 0
    match_data.each do |data|
      match = Match.find_or_initialize_by(uid: data[:fixture][:id]) do |m|
        m.home_team = clubs[data[:teams][:home][:id]]
        m.away_team = clubs[data[:teams][:away][:id]]
        m.location = data[:fixture][:venue][:name].presence || clubs[data[:teams][:home][:id]].name
      end
      match.season = year
      match.kickoff = Time.zone.parse(data[:fixture][:date])
      if data[:fixture][:status][:short].in? %w[FT AET PEN]
        match.home_goals = data[:goals][:home]
        match.away_goals = data[:goals][:away]
      end
      added += 1 if match.new_record?
      changed += 1 if !match.new_record? && match.changed?
      errors += match.errors.full_messages.map { |m| "#{data[:id]}: #{m}" } unless match.save
    end
    flash[:notice] = "#{match_data.length} matches synced: #{added} added, #{changed} changed."
    flash[:alert] = errors.join(', ') if errors.any?
    redirect_to matches_path
  end

  # GET /matches/new
  def new
    @match = Match.new
  end

  # GET /matches/1/edit
  def edit; end

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

  def check_for_matches_to_update
    redirect_to matches_path, flash: { notice: 'There were no matches to update.' } if matches_to_update.empty?
  end

  def matches_to_update
    @finished_matches_to_update ||= Match.where('(home_goals IS NULL OR away_goals IS NULL) AND kickoff < ?', Time.current - 2.hours)
  end

  def matches_to_update_by_week
    matches_to_update.group_by { |m| m.kickoff.to_date.beginning_of_week }
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_match
    @match = Match.all_seasons.with_clubs.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the allowlist through.
  def match_params
    params.require(:match).permit(:home_team_id, :away_team_id, :kickoff, :kickoff_date, :kickoff_time, :location, :home_goals, :away_goals)
  end

  def scrape_all_results_for_week(html)
    matches = html.css('.ml-link')
    matches.map { |match| scrape_single_result(match) }
  end

  def scrape_single_result(match)
    return {} unless match.at_css('.sb-match-date').try(:content).present?
    result = { date: match.at_css('.sb-match-date').content.to_date }
    %w(home away).each do |team|
      data = match.at_css(".sb-#{team}")
      result[team.to_sym] = {
        team: data.at_css('.sb-club-name-short').content,
        goals: data.at_css('.sb-score').present? ? data.at_css('.sb-score').content.to_i : nil
      }
    end
    result
  end

  # For use in +import+
  def retrieve_document(url)
    uri = URI(url)
    req = Net::HTTP::Get.new(uri.path)
    response = Net::HTTP.start(uri.host, uri.port) { |http| http.request(req) }
    if response.code_type.in? [Net::HTTPRedirection, Net::HTTPFound]
      response = Net::HTTP.get(URI(response['location']))
    end
    response.body
  end
end
