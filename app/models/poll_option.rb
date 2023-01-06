# frozen_string_literal: true

class PollOption < ActiveRecord::Base
  belongs_to :poll
  has_many :poll_votes, dependent: :destroy
  has_many :users, through: :poll_votes

  validates :title, presence: true
  validates :poll, presence: true

  has_attached_file :image, styles: { medium: '300x300>', thumb: '100x100>' }, default_url: '/images/:style/missing.png'
  validates_attachment_content_type :image, content_type: %r{\Aimage\/.*\z}
end
