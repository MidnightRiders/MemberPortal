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
  belongs_to :match
  belongs_to :user

  default_scope { includes(:match) }

  validates :user, :match, :home_goals, :away_goals, presence: true
  validates_uniqueness_of :match_id, scope: :user_id, message: 'has already been voted on by this user.'
  validate :is_revs_match

  # Returns *String*. Provides predicted score, if available.
  # Otherwise string is empty.
  def to_s
    predicted_score || ''
  end

  # Returns *String* or +nil+. Formatted 'Home – Away'.
  def predicted_score
    "#{home_goals} – #{away_goals}" unless (home_goals.nil? || away_goals.nil?)
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

  # Returns *Integer*
  def self.score
    sum(:score)
  end

  # Validates that one of the teams is the Revs.
  def is_revs_match
    errors.add(:match_id, 'is not a Revolution match') unless match.teams.map(&:abbrv).include? 'NE'
  end
end
