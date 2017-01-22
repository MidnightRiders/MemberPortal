class PickEm < ActiveRecord::Base
  default_scope { includes(:match) }

  # Possible PickEm/Match results and their corresponding integer values.
  RESULTS = { home: 1, draw: 0, away: -1 }.freeze

  belongs_to :match, -> { unscope(where: :season).all_seasons }
  belongs_to :user
  validates :match, :user, presence: true
  validates :match_id, uniqueness: { scope: :user_id, message: 'has already been voted on by this user.' }
  validates :result, inclusion: RESULTS.values

  validate :voteable?

  # Returns *Boolean*. Verifies that the +correct+ exists and is +false+
  def incorrect?
    correct == false
  end

  # Returns *Boolean*. Alias for <tt>incorrect?</tt>.
  def wrong?
    incorrect?
  end

  def result_key
    RESULTS.key(result)
  end

  # Returns *Integer*
  def self.score
    where(correct: true).size
  end

  # TODO: Implement "pick goalscorers" method (and corresponding models)

  private

  # TODO: Clarify usage in comparison to <tt>Match.voteable?</tt>

  # Validates that the match can be voted on, because the match is in the future
  def voteable?
    errors.add(:base, 'Cannot vote on past matches') unless match.in_future?
  end

end
