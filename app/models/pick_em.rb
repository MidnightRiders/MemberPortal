class PickEm < ActiveRecord::Base
  default_scope { includes(:match) }

  RESULTS = { home: 1, draw: 0, away: -1 }
  belongs_to :match
  belongs_to :user
  validates :match, :user, presence: true
  validates_uniqueness_of :match_id, scope: :user_id, message: 'has already been voted on by this user.'
  validates :result, inclusion: RESULTS.values

  validate :voteable?

  def correct?
    (match_id &&
        result) &&
        match.kickoff.past? &&
        !match.result.nil? &&
        result == RESULTS[match.result]
  end
  def incorrect?
    (match && result) && match.kickoff.past? && !match.result.nil? && result != RESULTS[match.result]
  end
  def wrong?
    incorrect?
  end
  def voteable?
    errors.add(:base, 'Cannot vote on past matches') unless match.kickoff.future?
  end

  # TODO: Implement "pick goalscorers" method (and corresponding models)

end
