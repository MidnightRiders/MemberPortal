class RevGuess < ActiveRecord::Base
  belongs_to :match
  belongs_to :user

  default_scope { includes(:match) }

  validates :user, :match, :home_goals, :away_goals, presence: true
  validates_uniqueness_of :match_id, scope: :user_id, message: 'has already been voted on by this user.'
  validate :is_revs_match

  def score
    if match.complete?
      sum = 0
      sum += 2 if match.result == result
      sum += 1 if home_goals == match.home_goals
      sum += 1 if away_goals == match.away_goals
      sum += 1 if (home_goals - away_goals) == (match.home_goals - match.away_goals)
      sum
    else
      nil
    end
  end

  def to_s
    predicted_score || ''
  end

  def predicted_score
    "#{home_goals} – #{away_goals}" unless (home_goals.nil? || away_goals.nil?)
  end

  def result
    if home_goals.nil? || away_goals.nil?
      nil
    else
      if home_goals > away_goals
        :home
      elsif away_goals > home_goals
        :away
      else
        :draw
      end
    end
  end

  def is_revs_match
    errors.add(:match_id, 'is not a Revolution match') unless match.teams.include? Club.find_by(abbrv: 'NE')
  end
end
