class PickEm < ActiveRecord::Base
  RESULTS = { home: 1, draw: 0, away: -1 }
  belongs_to :match
  belongs_to :user
  validates :match, :user, presence: true
  validates_uniqueness_of :match_id, scope: :user_id, message: 'has already been voted on by this user.'
  validates :result, inclusion: RESULTS.values

  validate :voteable, message: 'is no longer open for voting.'

  def correct?
    (match && result) && match.kickoff.past? && result == RESULTS[match.result]
  end
  def incorrect?
    (match && result) && match.kickoff.past? && result != RESULTS[match.result]
  end
  def wrong?
    incorrect?
  end

  private
    def voteable
      match.kickoff > Time.now
    end
end
