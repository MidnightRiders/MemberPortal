# Controller for +Match+ model.
class MatchesController < ApplicationController
  load_and_authorize_resource
  require 'net/http'
  require 'nokogiri'

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
    @mot_m_players = Player.includes(:mot_m_firsts,:mot_m_seconds,:mot_m_thirds).select{|x| x.mot_m_total(match_id: @match.id) && x.mot_m_total(match_id: @match.id) > 0 }.sort_by{|x| x.mot_m_total(match_id: @match.id)}.reverse if @match.teams.include? revs
  end

  # TODO: Allow updated URLs and/or alternate sources

  # Imports matches from MLS Calendar.
  def import
    calendar = retrieve_document(params[:url])
    count = Match.import_ics(calendar).size
    redirect_to matches_path, success: "#{count} Matches were saved or updated."
  rescue => e
    logger.error "Error during Match import: #{e.message}"
    logger.info e.backtrace&.join("\n")
    redirect_to matches_path, alert: e.message and return
  end

  # GET /matches/auto_update
  def auto_update
    finished_matches = Match.where('(home_goals IS NULL OR away_goals IS NULL) AND kickoff < ?', Time.current - 2.hours)
    matches_by_week = finished_matches.group_by { |m| [m.kickoff.year, m.kickoff.strftime('%W')] }
    successes = 0
    failures = []
    matches_by_week.each do |(_year, _week), matches|
      week_start = matches.first.kickoff.to_date.beginning_of_week
      uri = URI("http://matchcenter.mlssoccer.com/matches/#{week_start.strftime('%Y-%m-%d')}")
      html = Nokogiri::HTML(Net::HTTP.get(uri))
      matches.each do |match|
        Rails.logger.info match
        match_html = html.xpath('//*[contains(@class,"ml-link") and ' +
          ".//*[contains(@class, 'sb-home')]//*[contains(@class, 'sb-club-name-short') and contains(text(), '#{match.home_team.abbrv}')] and " +
          ".//*[contains(@class, 'sb-away')]//*[contains(@class, 'sb-club-name-short') and contains(text(), '#{match.away_team.abbrv}')]]").try(:first)
        next unless match_html.present?
        if (match_info = scrape_single_result(match_html))[:date] == match.kickoff.to_date
          if match_info[:home][:goals].present? && match_info[:away][:goals].present?
            if match.update_attributes(
                home_goals: match_info[:home][:goals],
                away_goals: match_info[:away][:goals]
              )
              successes += 1
            else
              failures << [match, 'Could not save (see logs).']
              Rails.logger.info match.errors.to_yaml
            end
          else
            failures << [match, 'No score recorded.']
            Rails.logger.warn 'No score recorded:'
            Rails.logger.info match_info.to_yaml
          end
        else
          failures << [match, 'Dates do not match.']
          Rails.logger.warn 'Dates do not match:'
          Rails.logger.info match.to_yaml
          Rails.logger.info match_info.to_yaml
        end
      end
    end
    if finished_matches.empty?
      flash[:notice] = 'There were no matches to update.'
    else
      flash[:success] = "#{successes} of #{finished_matches.size} #{'Match'.pluralize(finished_matches.size)} were updated."
      if failures.any?
        flash[:success] += '<br><ul><li>' + failures.map do |m, e|
          "#{view_context.link_to "#{m.home_team.abbrv} v #{m.away_team.abbrv}", m}: #{e}"
        end.join('</li><li>') + '</li></ul>'
      end
    end
    redirect_to matches_path
  rescue => e
    flash[:error] = e.message
    Rails.logger.error e.message
    Rails.logger.info e.backtrace.to_yaml
    redirect_to matches_path
  end

  # POST /matches/bulk_update
  def bulk_update
    updated = 0
    matches = CSV.table(params[:file].path.to_s)
    matches.each do |m|
      d = m[:date].to_date.beginning_of_day
      match = Match.find_by(kickoff: (d..d+1.day), home_team: Club.find_by(abbrv: m[:home]), away_team: Club.find_by(abbrv: m[:away]), home_goals: nil, away_goals: nil)
      if match.present?
        updated += 1 if match.update_attributes(home_goals: m[:hg], away_goals: m[:ag])
      else
        logger.error "Bulk Import Error: no incomplete Match found for #{m[:home]} v #{m[:away]} on #{m[:date]} (#{d})"
      end
    end
    redirect_to matches_path, notice: "#{updated}/#{matches.length} Matches were successfully updated."
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
