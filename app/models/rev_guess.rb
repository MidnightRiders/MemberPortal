# == Schema Information
#
# Table name: rev_guesses
#
#  id         :integer          not null, primary key
#  match_id   :integer
#  user_id    :integer
#  home_goals :integer
#  away_goals :integer
#  comment    :string(255)
#  score      :integer
#  created_at :datetime
#  updated_at :datetime
#

class RevGuess < ActiveRecord::Base
  belongs_to :match, -> { unscope(where: :season).all_seasons }
  belongs_to :user

  default_scope do includes(:match) end

  validates :user, :match, :home_goals, :away_goals, presence: true
  validates :match_id, uniqueness: { scope: :user_id, message: 'has already been voted on by this user.' }
  validate :is_revs_match

  # Returns *String*. Provides predicted score, if available.
  # Otherwise string is empty.
  def to_s
    predicted_score || ''
  end

  # Returns *String* or +nil+. Formatted 'Home – Away'.
  def predicted_score
    "#{home_goals} – #{away_goals}" unless home_goals.nil? || away_goals.nil?
  end

  # Returns *Symbol* or +nil+: +:home+, +:away+, or +:draw+.
  def result
    unless home_goals.nil? || away_goals.nil?
      if home_goals > away_goals
        :home
      elsif away_goals > home_goals
        :away
      else
        :draw
      end
    end
  end

  # Validates that one of the teams is the Revs.
  def is_revs_match
    errors.add(:match_id, 'is not a Revolution match') unless match.teams.map(&:abbrv).include? 'NE'
  end

  # Returns *Integer*
  def self.score(season = Date.current.year)
    joins(:match).where(matches: { season: season }).sum(:score)
  end
end
