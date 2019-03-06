require 'net/http'

# Controller for +Match+ model.
class MatchesController < ApplicationController
  authorize_resource
  before_action :set_match, only: %i(show edit update destroy)
  before_action :check_for_matches_to_update, only: %i(auto_update)

  # GET /matches
  # GET /matches.json
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
  end

  # GET /matches/1
  # GET /matches/1.json
  def show
    @order_point = @match.order_selected(Match.all_seasons)
    @mot_m_players = Player.includes(:mot_m_firsts, :mot_m_seconds, :mot_m_thirds).select { |x| x.mot_m_total(match_id: @match.id) && x.mot_m_total(match_id: @match.id) > 0 }.sort_by { |x| x.mot_m_total(match_id: @match.id) }.reverse if @match.teams.include? revs
  end

  # GET /matches/sync
  def sync
    match_data = JSON.parse(
      URI.parse('http://mls-data-gatherer.herokuapp.com/').read,
      symbolize_names: true
    )[:fixtures]
    clubs = Club.all.map { |c| [c.abbrv, c] }.to_h
    errors = []
    changed = 0
    added = 0
    match_data.each do |fixture|
      match = Match.find_or_initialize_by(uid: fixture[:id]) do |m|
        m.home_team = clubs[Match::API_CLUB_IDS[fixture[:HomeTeam][:id]]]
        m.away_team = clubs[Match::API_CLUB_IDS[fixture[:AwayTeam][:id]]]
        m.location = clubs[Match::API_CLUB_IDS[fixture[:HomeTeam][:id]]].name
      end
      match.kickoff = Time.zone.parse(fixture[:matchDate])
      if fixture[:status] == '6'
        match.home_goals = fixture[:homeScore]
        match.away_goals = fixture[:awayScore]
      end
      added += 1 if match.new_record?
      changed += 1 if !match.new_record? && match.changed?
      errors += match.errors.full_messages.map { |m| "#{fixture[:id]}: #{m}" } unless match.save
    end
    flash[:notice] = "#{match_data.length} matches synced: #{added} added, #{changed} changed."
    flash[:error] = errors.join(', ') if errors.any?
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

  def auto_update_match(score, match)
    if score.present?
      match.update_attributes(score) ? true : Rails.logger.info(match.errors.to_yaml) && false
    else
      Rails.logger.warn 'No match found:'
      Rails.logger.info match.to_yaml
    end
  end

  def auto_update_week(date, matches)
    importer = MatchScoreRetriever.new
    matches.map do |match|
      auto_update_match(importer.match_info_for(match), match)
    end
  end

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

  # Never trust parameters from the scary internet, only allow the white list through.
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
