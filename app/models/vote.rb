class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :post, polymorphic: true

  validates :value, numericality: { in: [-1, 1] }
end
