class Product < ActiveRecord::Base
  has_many :product_orders
  has_many :orders, through: :product_orders

  has_attached_file :image, {
    styles: {
      original: '400x600',
      medium:   '150x150',
      thumb:    '75x75#'
    },
    default_style: :original,
    storage: :s3
  }

  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  def available?
    stock.nil? || stock > 0
  end

  def unavailable?
    !available?
  end
end
