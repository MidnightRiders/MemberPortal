# frozen_string_literal: true

class PollVote < ActiveRecord::Base
  belongs_to :poll_option
  has_one :poll, through: :poll_option
  belongs_to :user

  validate :voteable?, on: :create
  validate :multi_votes, on: :create

  validates :poll_option, presence: true
  validates :user, presence: true

  private

  def voteable?
    errors.add(:base, 'poll is closed') unless poll_option.poll.active?
  end

  def multi_votes
    errors.add(:base, 'user has no votes remaining') if poll_option.poll.multiple_choice&.tap { user.votes_for_poll(poll).count < _1 }
  end
end
