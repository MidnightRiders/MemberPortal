class Discussion < ActiveRecord::Base
  include Voteable

  belongs_to :match
  belongs_to :user
  has_many :comments
  has_many :votes, as: :post

  after_create :auto_upvote

  has_paper_trail on: [ :update ], only: [ :content ]

  default_scope do
    includes(:comments)
      .joins('LEFT OUTER JOIN votes ON discussions.id = votes.post_id AND \'Discussion\' = votes.post_type')
      .select('discussions.*, COALESCE(SUM(votes.value), 0) AS score')
      .group('discussions.id')
      .order('EXTRACT(year FROM discussions.created_at) DESC, EXTRACT(week FROM discussions.created_at) DESC, score DESC')
  end

  def top_level_comments
    comments.where(comment_id: nil)
  end

  private
    def auto_upvote
      upvote(self.user_id)
    end
end
