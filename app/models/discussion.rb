class Discussion < ActiveRecord::Base
  belongs_to :match
  belongs_to :user
  has_many :comments
  has_many :votes, as: :post

  has_paper_trail on: [ :update ], only: [ :content ]

  default_scope do
    includes(:comments)
      .joins('LEFT OUTER JOIN votes ON discussions.id = votes.post_id AND \'Discussion\' = votes.post_type')
      .select('discussions.*, COALESCE(SUM(votes.value), 0) AS score')
      .group('discussions.id')
      .order('EXTRACT(year FROM discussions.created_at) DESC, EXTRACT(week FROM discussions.created_at) DESC, score DESC')
  end

  def score
    self['score'] || votes.sum(:value) || 0
  end
end
