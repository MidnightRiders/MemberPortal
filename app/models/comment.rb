class Comment < ActiveRecord::Base
  belongs_to :discussion
  belongs_to :user
  belongs_to :parent_comment, class_name: 'Comment', foreign_key: :comment_id
  has_many :comments
  has_many :votes, as: :post

  has_paper_trail on: [ :update ], only: [ :content ]

  default_scope do
    includes(:comments)
      .joins('LEFT OUTER JOIN votes ON comments.id = votes.post_id AND \'Comment\' = votes.post_type')
      .select('comments.*, COALESCE(SUM(votes.value), 0) AS score')
      .group('comments.id')
      .order('score DESC, created_at DESC')
  end

  validates_associated :user
  validate :has_parent

  def parent
    discussion || parent_comment
  end

  private
  def has_parent
    errors.add(:discussion_id, 'must be in response to a comment or discussion') unless discussion.present? || parent_comment.present?
  end

  def has_one_parent
    errors.add(:comment_id, 'cannot respond to both a discussion and a comment') if discussion.present? && parent_comment.present?
  end
end
