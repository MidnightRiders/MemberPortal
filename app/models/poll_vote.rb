# frozen_string_literal: true

class PollVote < ActiveRecord::Base
  belongs_to :poll_option
  has_one :poll, through: :poll_option
  belongs_to :user

  validate :votable, on: :create
  validate :multi_votes, on: :create
  validate :user_is_member

  validates :poll_option, presence: true
  validates :user, presence: true

  private

  def votable
    errors.add(:base, 'poll is closed') unless poll.active?
  end

  def multi_votes
    errors.add(:base, 'too many votes cast') if poll.multiple_choice&.then { user.votes_for_poll(poll).count > _1 }
  end

  def user_is_member
    errors.add(:user, 'must be a member') unless user.current_member?
  end
end
