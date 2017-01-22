# Model belonging to +User+ containing membership information for a given year.
#
class Membership < ActiveRecord::Base
  delegate :url_helpers, to: 'Rails.application.routes'

  store_accessor :privileges
  TYPES = %w(Individual Family Relative).freeze
  COSTS = { Individual: '1061', Family: '2091' }.freeze
  PRIVILEGES = %w(admin executive_board at_large_board).freeze

  attr_accessor :stripe_card_token

  hstore_accessor :info,
                  stripe_subscription_id: :string,
                  stripe_charge_id: :string,
                  override: :integer,
                  pending_approval: :boolean,
                  invited_email: :string

  belongs_to :user

  default_scope -> { where(refunded: nil).order(year: :asc) }
  scope :refunds, -> { unscoped.where.not(refunded: nil).order(year: :asc) }
  scope :current, ->(year = Date.current.year) { includes(:user).where(year: year, refunded: [nil, false]).where.not(user_id: nil) }
  scope :for_year, ->(year = nil) { current(year) }

  before_validation :remove_blank_privileges

  validates :year, presence: true, inclusion: { in: (Date.current.year..Date.current.year + 1) }, uniqueness: { scope: [:user_id], conditions: -> { where(refunded: nil) } }
  validates :type, presence: true, inclusion: { in: TYPES, message: 'is not valid' }
  validate :accepted_privileges
  validate :stripe_subscription_is_unique?
  validate :stripe_charge_is_unique?
  validate :paid_for?

  # Returns *String*. Lists all privileges, comma-separated or in plain english if +verbose+ is true.
  def list_privileges(verbose = false, no_admin = false)
    ps = privileges.map(&:titleize)
    ps = ps.reject { |v| v == 'admin' } if no_admin
    if privileges.empty?
      'None'
    elsif verbose
      ps.to_sentence
    else
      ps.join(', ')
    end
  end

  def privileges
    self[:privileges] || []
  end

  def overriding_admin
    return nil unless override.present?
    Membership.includes(:user).find_by(users: { id: override }, year: year)&.user
  end

  def subscription?
    stripe_subscription_id.present?
  end

  def cost
    cost = self.class.price.to_f / 100
    override.present? ? cost.floor : cost
  end

  # Save with Stripe payment if applicable
  def save_with_payment(card_id = nil)
    return unless ready_to_pay?

    user.create_or_update_stripe_customer(stripe_card_token)

    user.subscribe_to_membership(self) if subscribe?
    make_stripe_charge(card_id)

    save
  end

  def make_stripe_charge(card_id = nil)
    self.stripe_charge_id = Stripe::Charge.create(charge_information(card_id)).id
  rescue Stripe::StripeError => e
    logger.error "Stripe error while saving membership with payment: #{e.message}"
    errors.add :base, "There was a problem with your credit card: #{e.message}"
  end

  def charge_information(card_id = nil)
    {
      customer: user.stripe_customer.id,
      description: stripe_description,
      metadata: stripe_metadata,
      receipt_email: user.email,
      amount: self.class.price,
      currency: 'usd',
      statement_descriptor: stripe_statement_descriptor,
      source: card_id || user.stripe_customer.default_source
    }
  end

  def stripe_description
    "Midnight Riders #{year} #{type.titleize} Membership"
  end

  def stripe_statement_descriptor
    "MRiders #{year} #{type.to_s[0..2].titleize} Mem"
  end

  def stripe_metadata
    {
      year: year,
      type: type.titleize
    }
  end

  # Cancel current subscription
  def cancel(provide_refund = false)
    self.refunded = 'canceled' unless cancel_stripe_subscription
    save!
    refund if provide_refund
  rescue Stripe::StripeError => e
    logger.error "Stripe error while canceling customer: #{e.message}"
    errors.add :base, 'There was a problem with your credit card: ' + e.message
    false
  end

  def cancel_stripe_subscription
    return false unless subscription?
    user.stripe_customer.subscriptions.retrieve(stripe_subscription_id).delete
    self.stripe_subscription_id = nil
  end

  # Refund payment if possible
  def refund
    stripe_refund if user.stripe_customer.present?
    self.refunded ||= 'true'
    save
  rescue Stripe::StripeError => e
    logger.error "Stripe error while refunding customer: #{e.message}"
    errors.add :base, 'There was a problem refunding the transaction.'
    false
  end

  def stripe_refund
    return unless stripe_charge_id
    self.refunded = stripe_charge&.refunds&.create.id
  rescue => e
    logger.error "Stripe Refund error: #{e.message}"
    logger.info e.backtrace.to_yaml
  end

  def stripe_charge
    user.stripe_customer.charges.retrieve(stripe_charge_id)
  end

  def info
    (self[:info] || {}).with_indifferent_access
  end

  def can_have_relatives?
    is_a?(Family) || is_a?(Relative)
  end

  def any_relatives?
    can_have_relatives? && relatives.present?
  end

  def notify_slack
    SlackBot.post_message("New #{type} Membership for #{user.first_name} #{user.last_name} (<#{url_helpers.user_url(user)}|@#{user.username}>):\n*#{year} Total: #{Membership.for_year(year).count}* | #{Membership.breakdown(year)}", 'membership')
  end

  def previous
    @previous ||= user.memberships.find_by(year: year)
  end

  def subscribe
    @subscribe ||= false
  end
  alias subscribe? subscribe

  def subscribe=(value)
    @subscribe = value.to_i == 1
  end

  def self.breakdown(season = Date.current.year)
    breakdown = for_year(season).group(:year, :type).count
    %w(Individual Family Relative).map { |type| "#{type}: #{breakdown[[season, type]] || 0}" }.join(' | ')
  end

  def self.price
    '1061'
  end

  private

  def ready_to_pay?
    valid? && !overriding_admin && !is_a?(Relative)
  end

  def remove_blank_privileges
    privileges.try(:reject!, &:blank?)
  end

  def accepted_privileges
    errors.add(:privileges, 'include unaccepted values') if privileges && (privileges - PRIVILEGES).present?
  end

  def able_to_change_privileges
    ability = Ability.new(user)
    errors.add(:privileges, 'cannot be changed in this way by this user') if privileges.changed? && ability.cannot?(:grant_privileges, Membership)
  end

  def paid_for?
    return if is_a?(Relative)
    errors.add(:base, 'must be paid for') unless stripe_charge_id || # Charge gone through
      stripe_card_token || # To keep model valid before charge
      user.stripe_customer_token || # To keep model valid before charge
      overriding_admin # Paid for in person; override recorded
  end

  def stripe_subscription_is_unique?
    errors.add(:info, 'contains a redundant Stripe Subscription ID') if Membership.where.not(id: id).with_stripe_subscription_id(stripe_subscription_id).present?
  end

  def stripe_charge_is_unique?
    errors.add(:info, 'contains a redundant Stripe Charge ID') if Membership.where.not(id: id).with_stripe_charge_id(stripe_charge_id).present?
  end
end
