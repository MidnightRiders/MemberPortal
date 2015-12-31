class Comment < ActiveRecord::Base
  include Voteable

  belongs_to :discussion
  belongs_to :user
  belongs_to :parent_comment, class_name: 'Comment', foreign_key: :comment_id
  has_many :comments
  has_many :votes, as: :post

  after_create :auto_upvote

  has_paper_trail on: [ :update ], only: [ :content ]

  default_scope do
    includes(:comments)
      .joins('LEFT OUTER JOIN votes ON comments.id = votes.post_id AND \'Comment\' = votes.post_type')
      .select('comments.*, COALESCE(SUM(votes.value), 0) AS score')
      .group('comments.id')
      .order('score DESC, created_at DESC')
  end

  validates_associated :user, :discussion
  validates :discussion_id, presence: true
  validate :has_parent

  def parent
    parent_comment || discussion
  end

  private
    def has_parent
      errors.add(:discussion_id, 'must be in response to a comment or discussion') unless discussion.present? || parent_comment.present?
    end

    def auto_upvote
      upvote(self.user_id)
    end
end
