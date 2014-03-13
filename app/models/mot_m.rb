class MotM < ActiveRecord::Base
  validates :user, :match, :first, associated: true, presence: true
  validates :second, :third, associated: true, allow_nil: true

  validate :different_picks, message: 'must be different players'
  validate :voteable?, message: 'cannot be voted on yet'
  validates_uniqueness_of :match_id, scope: :user_id, message: 'has already been voted on by this user.'

  belongs_to :user
  belongs_to :match
  belongs_to :first, class_name: 'Player'
  belongs_to :second, class_name: 'Player'
  belongs_to :third, class_name: 'Player'

  private
    def different_picks
      picks = [first_id, second_id, third_id].reject(&:blank?)
      !picks.detect{|e| picks.count(e) > 1 }
    end

    def voteable?
      match.voteable?
    end
end
