class ProductOrder < ActiveRecord::Base
  belongs_to :product
  belongs_to :order
end
