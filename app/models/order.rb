class Order < ActiveRecord::Base
  belongs_to :user
  has_many :product_orders
  has_many :products, through: :product_orders

  def place
    raise 'Cart is empty' if products.empty?
    raise 'Order has already been placed' if placed?

    unavailable_products = products.map(&:unavailable?)
    raise "The following products are not in stock: #{unavailable_products}" if unavailable_products.any?
  end

  def placed?
    completed_at.present?
  end
end
