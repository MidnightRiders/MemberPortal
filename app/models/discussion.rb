class Discussion < ActiveRecord::Base
  belongs_to :match
  belongs_to :user
  has_many :comments
  has_many :votes, as: :post

  has_paper_trail on: [ :update ], only: [ :content ]
end
