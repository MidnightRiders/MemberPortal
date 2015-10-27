class Comment < ActiveRecord::Base
  belongs_to :discussion
  belongs_to :user
  belongs_to :parent_comment, class_name: 'Comment', foreign_key: :comment_id
  has_many :comments
  has_many :votes, as: :post

  validates_associated :user
  validate :has_parent

  private
  def has_parent
    errors.add(:discussion_id, 'must be in response to a comment or discussion') unless discussion.present? || parent_comment.present?
  end
end
