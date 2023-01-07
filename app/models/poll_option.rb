# frozen_string_literal: true

class PollOption < ActiveRecord::Base
  belongs_to :poll
  has_many :poll_votes, dependent: :destroy
  has_many :users, through: :poll_votes

  validates :title, presence: true
  validates :poll, presence: true

  has_attached_file :image, styles: { large: '800x800>', medium: '300x300>', thumb: '100x100>' }, default_url: '/images/:style/missing.png'
  validates_attachment_content_type :image, content_type: %r{\Aimage\/.*\z}

  def percent_votes
    return 0 if poll.total_votes.zero?
    (poll_votes.distinct(:user_id).count(:user_id).to_f / poll.poll_votes.distinct(:user_id).count(:user_id) * 100)
  end
end
