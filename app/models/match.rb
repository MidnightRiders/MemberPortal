# == Schema Information
#
# Table name: matches
#
#  id           :integer          not null, primary key
#  home_team_id :integer
#  away_team_id :integer
#  kickoff      :datetime
#  location     :string(255)
#  home_goals   :integer
#  away_goals   :integer
#  created_at   :datetime
#  updated_at   :datetime
#  uid          :string(255)
#

class Match < ActiveRecord::Base
  belongs_to :home_team, class_name: 'Club'
  belongs_to :away_team, class_name: 'Club'

  default_scope -> {
    where(season: Date.current.year)
  }
  scope :all_seasons, -> {
    unscope(where: :season)
  }
  scope :with_clubs, -> {
    includes(:home_team,:away_team)
  }
  scope :completed, -> {
    where.not(home_goals: nil, away_goals: nil)
  }
  scope :upcoming, -> {
    where('kickoff > ?', Time.current)
  }

  has_many :mot_ms
  has_many :rev_guesses
  has_many :pick_ems

  before_validation :check_for_season

  validates :home_team, :away_team, :kickoff, :location, presence: true
  validates :home_goals, :away_goals, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :home_goals, presence: { if: -> { !away_goals.blank? } }
  validates :away_goals, presence: { if: -> { !home_goals.blank? } }
  validates :season, presence: true
  validates :uid, uniqueness: { case_sensitive: true, allow_blank: true }

  after_save :update_games, if: -> { complete? }

  date_time_attribute :kickoff

  # Returns *String*: 'home – away' or '–' if not +complete?+.
  def score
    if complete?
      "#{home_goals || 0} – #{away_goals || 0}"
    else
      '—'
    end
  end

  # Returns *Boolean*. Determined by presence of home and away goals.
  def complete?
    home_goals.present? && away_goals.present?
  end

  # Returns *Symbol* or +nil+: +:home+, +:away+, or +:draw+
  def result
    if complete?
      if home_goals > away_goals
        :home
      elsif away_goals > home_goals
        :away
      else
        :draw
      end
    end
  end

  # Returns +Club+ or +nil+. Winning team if present.
  def winner
    if result == :home
      home_team
    elsif result == :away
      away_team
    end
  end

  # Returns +Club+ or +nil+. Losing team if present.
  def loser
    if result == :home
      away_team
    elsif result == :away
      home_team
    end
  end

  # TODO: Break this up to separate tests, and clarify distinction with <tt>PickEm.voteable?</tt>

  # Returns *Boolean*.
  # Tests if +kickoff+ was 45 minutes in the past, teams
  # include New England (used for +MotM+ and +RevGuess+), and
  # the game is less than two weeks old (can't choose +MotM+ for
  # old matches).
  def voteable?
    kickoff &&
      (kickoff + 45.minutes).past? &&
      teams.map(&:abbrv).include?('NE') &&
      kickoff >= 2.weeks.ago
  end

  # Returns *Boolean*. Shortcut to test if +kickoff+ is in the future, if it exists.
  def in_future?
    kickoff.try(:future?)
  end

  # Returns *Boolean*. Not <tt>in_future?</tt>.
  def in_past?
    !in_future?
  end

  # Returns *Array* with both teams: <tt>[ home_team, away_team ]</tt>
  def teams
    [ home_team, away_team ]
  end

  # Returns +Match+. Retrieves match immediately after the given match.
  def next
    Match.with_clubs.where('kickoff >= ?', kickoff).order('kickoff ASC, id ASC').select{|x| [x.home_team_id,x.away_team_id] != [home_team_id,away_team_id] && (x.id < id || x.kickoff > kickoff) }.first
  end

  # Returns +Match+. Retrieves match immediately before the given match.
  def previous
    Match.with_clubs.where('kickoff <= ?', kickoff).order('kickoff DESC, id DESC').select{|x| [x.home_team_id,x.away_team_id] != [home_team_id,away_team_id] && (x.id > id || x.kickoff < kickoff) }.first
  end

  # If n is 1 (default), returns +Match+. Otherwise, returns *Array* of +Matches+.
  # Retrieves previous +n+ matches from <tt>Time.current</tt>.
  def self.previous(n=1)
    ms = where('kickoff < ?', Time.current).order('kickoff DESC')
    if n==1
      ms.first
    else
      ms.first(n)
    end
  end

  # If n is 1 (default), returns +Match+. Otherwise, returns *Array* of +Matches+.
  # Retrieves next +n+ matches from <tt>Time.current</tt>.
  def self.next(n=1)
    ms = upcoming.order('kickoff DESC')
    if n==1
      ms.first
    else
      ms.first(n)
    end
  end

  # Updates the picking games on save so that they don't have to pull in +Match+ data
  # any and every time they need to evaluate scores
  def update_games
    unless rev_guesses.empty?
      rev_guesses.each do |rg|
        sum = 0
        sum += 2 if rg.result == result
        sum += 1 if rg.home_goals == home_goals
        sum += 1 if rg.away_goals == away_goals
        sum += 1 if (rg.home_goals - rg.away_goals) == (home_goals - away_goals)
        rg.update_attribute(:score, sum)
      end
    end
    pick_ems.each do |p|
      p.update_attribute(:correct, p.result == PickEm::RESULTS[result])
    end
  end

  # Check for season and create it if it doesn't exist
  def check_for_season
    season ||= kickoff.year
  end

end
