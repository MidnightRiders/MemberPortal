# frozen_string_literal: true

class Poll < ActiveRecord::Base
  has_many :poll_options, dependent: :destroy
  has_many :poll_votes, through: :poll_options

  accepts_nested_attributes_for :poll_options, reject_if: :all_blank, allow_destroy: true

  validates :title, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :multiple_choice, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, allow_nil: true
  validate :has_options
  validate :in_future, on: :update

  scope :active, -> { where(start_time: (..Time.current), end_time: (Time.current..)) }

  def active?
    Time.current.between?(start_time, end_time)
  end

  def inactive?
    !active?
  end

  def ordered_options
    poll_options.includes(:poll_votes).sort_by { _1.poll_votes.count }.reverse
  end

  def voted?(user)
    poll_votes.where(user: user).any?
  end

  def voted_options(user)
    poll_votes.where(user: user).map(&:poll_option)
  end

  def votes_for(option)
    poll_votes.where(poll_option: option).count
  end

  def total_votes
    poll_votes.count
  end

  private

  def has_options
    errors.add(:base, 'must have at least two options') unless poll_options.size > 1
  end

  def in_future
    errors.add(:start_time, 'must be in the future') if start_time < Time.current
  end
end
