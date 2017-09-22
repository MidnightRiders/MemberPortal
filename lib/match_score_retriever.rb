require 'open-uri'
require 'nokogiri'
require 'error_notifier'

class MatchScoreRetriever
  URL_ROOT = 'https://www.fotmob.com/leagues/130/matches/'.freeze
  CLUB_IDS = {
    '773958' => 'ATL',
    '6397' => 'CHI',
    '6001' => 'CLB',
    '8314' => 'COL',
    '6399' => 'DAL',
    '6602' => 'DC',
    '8259' => 'HOU',
    '6637' => 'LA',
    '207242' => 'MIN',
    '161195' => 'MTL',
    '6580' => 'NE',
    '6514' => 'NY',
    '546238' => 'NYC',
    '267810' => 'ORL',
    '191716' => 'PHI',
    '307690' => 'POR',
    '6606' => 'RSL',
    '130394' => 'SEA',
    '6603' => 'SJ',
    '6604' => 'SKC',
    '56453' => 'TOR',
    '307691' => 'VAN'
  }.freeze

  # @param [Date, DateTime] date
  def initialize
    html = Nokogiri::HTML(URI.parse(URL_ROOT).read)
    @data = data_from_doc(html).dig(:league, :fixtures)
  end

  # @param [Match] match
  def match_info_for(match)
    fixture = fixture_for(match)
    return nil unless fixture
    {
      home_goals: fixture[:homeScore].to_i,
      away_goals: fixture[:awayScore].to_i
    }
  end

  # @param [Match] match
  def fixture_for(match)
    @data.find { |fixture|
      CLUB_IDS[fixture[:homeTeam][:id]] == match.home_team.abbrv &&
      CLUB_IDS[fixture[:awayTeam][:id]] == match.away_team.abbrv &&
      compare_kickoff(fixture, match)
    }
  end

  private

  # @param [Match] match
  def compare_kickoff(fixture, match)
    kickoff = ActiveSupport::TimeZone.new('Europe/Copenhagen').parse(fixture[:matchDate]).in_time_zone(Time.zone)
    raise "Dates do not match: #{kickoff}/#{match.kickoff}" unless kickoff.to_date == match.kickoff.to_date
    true
  rescue => err
    ErrorNotifier.notify(err)
    false
  end

  def data_from_doc(html)
    JSON.parse(
      URI.unescape(
        html.xpath('//script[contains(., "window.__INITIAL_STATE__ = ")]')[0]
          .text.strip.sub(/\A.+?= "(.+?)(?<!\\)".*\z/m, '\1')
      ),
      symbolize_names: true
    )
  rescue => err
    ErrorNotifier.notify(err)
    {}
  end
end
