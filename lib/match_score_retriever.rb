require 'open-uri'
require 'nokogiri'

class MatchScoreRetriever
  URL_ROOT = 'https://matchcenter.mlssoccer.com/matches/'.freeze

  # @param [Date, DateTime] date
  def initialize(date)
    uri = "#{URL_ROOT}#{date.strftime('%Y-%m-%d')}"
    @html = Nokogiri::HTML(URI.parse(uri).read)
  end

  # @param [Match] match
  def match_info_for(match)
    match_entry = match_entry_for(match)
    return nil unless match_entry
    extract_score_from_html(match_entry)
  end

  # @param [Match] match
  def match_entry_for(match)
    @html.css('.ml-link').find { |item|
      item.at_css('.sb-home .sb-club-name-short').content == match.home_team.abbrv &&
      item.at_css('.sb-away .sb-club-name-short').content == match.away_team.abbrv &&
      compare_kickoff(item, match)
    }
  end

  private

  def extract_score_from_html(match_entry)
    {
      home_goals: match_entry.at_css('.sb-home .sb-score')&.content&.to_i,
      away_goals: match_entry.at_css('.sb-away .sb-score')&.content&.to_i
    }
  end

  # @param [Match] match
  def compare_kickoff(item, match)
    date = item.at_css('.sb-match-date')&.content
    return false if date.nil? || date == ''
    raise StandardError, "Dates do not match: #{date}/#{match.kickoff}" unless Date.parse(date) == match.kickoff.to_date
    true
  end
end
