require 'net/http'
require 'match_score_retriever'

# Controller for +Match+ model.
class MatchesController < ApplicationController
  authorize_resource
  before_action :set_match, only: %i(index show edit update destroy)
  before_action :determine_start_date, only: %i(index)
  before_action :set_rev_guess, only: %i(index), if: ->{ params[:rev_guess] }
  before_action :set_mot_m, only: %i(index), if: ->{ params[:mot_m] }
  before_action :check_for_matches_to_update, only: %i(auto_update)

  # GET /matches
  def index
    @match_index = serialized_matches

    respond_to do |format|
      format.html
      format.json { render json: @match_index.as_json }
    end
  end

  # GET /matches/1
  def show
    @order_point = @match.order_selected(Match.all_seasons)
    @mot_m_players = Player.includes(:mot_m_firsts, :mot_m_seconds, :mot_m_thirds).select { |x| x.mot_m_total(match_id: @match.id) && x.mot_m_total(match_id: @match.id) > 0 }.sort_by { |x| x.mot_m_total(match_id: @match.id) }.reverse if @match.teams.include? revs
    render json: @match, serializer: MatchSerializer, scope: view_context
  end

  # TODO: Allow updated URLs and/or alternate sources

  # Imports matches from MLS Calendar.
  def import
    calendar = retrieve_document(params[:url])
    count = Match.import_ics(calendar).size
    redirect_to matches_path, success: "#{count} Matches were saved or updated."
  rescue => err
    alert = ErrorNotifier.notify(err)
    redirect_to matches_path, alert: alert and return
  end

  # GET /matches/auto_update
  def auto_update
    successes = matches_to_update_by_week.map { |week, matches|
      auto_update_week(week, matches)
    }.flatten.count(true)
    redirect_to matches_path, flash: {
      success: "#{successes} of #{matches_to_update.size} #{'Match'.pluralize(matches_to_update.size)} were updated."
    }
  end

  # GET /matches/new
  def new
    @match = Match.new
  end

  # GET /matches/1/edit
  def edit; end

  # POST /matches
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
  def destroy
    @match.destroy
    respond_to do |format|
      format.html { redirect_to matches_url }
      format.json { head :no_content }
    end
  end

  private
  def determine_start_date
    return @start_date = @match.kickoff.beginning_of_week if @match.present?
    @start_date = (params[:date].try(:in_time_zone, Time.zone) || Time.current).beginning_of_week
  end

  def serialized_matches
    MatchWeekSerializer.new(
      prepared_matches,
      serializer: MatchWeekSerializer,
      scope: view_context,
      start_date: @start_date,
      pick_em: @pick_em,
      rev_guess: @rev_guess,
      mot_m: @mot_m
    )
  end

  def auto_update_match(score, match)
    if score.present?
      match.update_attributes(score) ? true : Rails.logger.info(match.errors.to_yaml) && false
    else
      Rails.logger.warn 'No match found:'
      Rails.logger.info match.to_yaml
    end
  end

  def auto_update_week(date, matches)
    importer = MatchScoreRetriever.new(date)
    matches.map do |match|
      begin
        auto_update_match(importer.match_info_for(match), match)
      rescue => error
        ErrorNotifier.notify(error)
        false
      end
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

  # Never trust parameters from the scary internet, only allow the white list through.
  def match_params
    params.require(:match).permit(:home_team_id, :away_team_id, :kickoff, :kickoff_date, :kickoff_time, :location, :home_goals, :away_goals)
  end

  def prepared_matches
    Match.for_week(@start_date)
      .includes(:pick_ems, :rev_guesses, :mot_ms)
      .with_clubs
  end

  # Use callbacks to share common setup or constraints between sactions.
  def set_match
    @match = Match.all_seasons.with_clubs.find(params[:match_id])
  rescue => e
    raise e unless action_name == 'index'
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

  def set_rev_guess
    authorize! :create, RevGuess
    @rev_guess = @match.rev_guesses.find_or_initialize_by(user_id: current_user.id)
  end

  def set_mot_m
    authorize! :create, MotM
    @mot_m = @match.mot_ms.find_or_initialize_by(user_id: current_user.id)
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
