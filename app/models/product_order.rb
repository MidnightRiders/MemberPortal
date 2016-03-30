class ProductOrder < ActiveRecord::Base
  belongs_to :product
  belongs_to :order

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :product, :order, presence: true
  validates_associated :product
  validates_associated :order
  validate :product_available

  private

  def product_available
    errors.add(:product_id, 'is not currently available') if product.unavailable?
  end
end
