class MotM < ActiveRecord::Base
  validates :user, :match, :first, associated: true, presence: true
  validates :second, :third, associated: true, allow_nil: true

  validate :different_picks
  validate :voteable?
  validates_uniqueness_of :match_id, scope: :user_id, message: 'has already been voted on by this user.'

  belongs_to :user
  belongs_to :match
  belongs_to :first, class_name: 'Player'
  belongs_to :second, class_name: 'Player'
  belongs_to :third, class_name: 'Player'

  private
    def different_picks
      errors.add(:second,'must be different player') if first_id == second_id
      errors.add(:third,'must be different player') if second_id == third_id || first_id == third_id
    end

    def voteable?
      errors.add(:base, 'Cannot vote for matches in future.') unless match.voteable?
    end
end
