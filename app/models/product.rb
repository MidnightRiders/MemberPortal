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
    default_url: '/assets/shop/default-:style.gif',
    storage: :s3
  }

  validates :name, :member_cost, presence: true
  validate :dates_in_order
  validate :member_discount
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  def in_stock?
    stock.nil? || stock > 0
  end

  def active?
    active &&
      (available_start.nil? || available_start < Time.current) &&
      (available_end.nil? || available_end > Time.current)
  end

  def available?
    in_stock? && active?
  end

  def members_only?
    non_member_cost.blank?
  end

  def unavailable?
    !available?
  end

  private
  def dates_in_order
    errors.add(:available_end, 'must come after start') if available_start.present? && available_start > available_end
  end

  def member_discount
    return unless member_cost.present?
    errors.add(:non_member_cost, 'cannot be below member cost') if non_member_cost.present? && non_member_cost < member_cost
  end
end
