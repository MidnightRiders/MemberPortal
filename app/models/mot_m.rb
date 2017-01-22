class MotM < ActiveRecord::Base

  validates :user, :match, :first, associated: true, presence: true
  validates :second, :third, associated: true, allow_nil: true

  validate :different_picks
  validate :voteable?
  validate :active_players
  validates :match_id, uniqueness: { scope: :user_id, message: 'has already been voted on by this user.' }

  belongs_to :user
  belongs_to :match, -> { unscope(where: :season) }
  belongs_to :first, class_name: 'Player'
  belongs_to :second, class_name: 'Player'
  belongs_to :third, class_name: 'Player'

  private

  # Validates that all votes are for distinct players
  def different_picks
    errors.add(:second, 'must be different player') if second_id && (first_id == second_id)
    errors.add(:third, 'must be different player') if third_id && (second_id == third_id || first_id == third_id)
  end

  # Validates that all votes are for active players
  def active_players
    errors.add(:first, 'must be an active player') unless first.active?
    errors.add(:second, 'must be an active player') if second && second.inactive?
    errors.add(:third, 'must be an active player') if third && third.inactive?
  end

  # TODO: Clarify error message.

  # Validates that the +Match+ is <tt>voteable?</tt>.
  def voteable?
    errors.add(:base, 'Cannot vote for matches in future.') unless match.voteable?
  end
end
