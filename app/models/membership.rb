# Model belonging to +User+ containing membership information for a given year.
#
# == Schema Information
#
# Table name: memberships
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  year       :integer
#  info       :hstore
#  privileges :json
#  type       :string
#  refunded   :string
#  created_at :datetime
#  updated_at :datetime
#

class Membership < ActiveRecord::Base
  store_accessor :privileges
  TYPES = %w( Individual Family Relative )
  COSTS = { Individual: '1061', Family: '2091' }
  PRIVILEGES = %w( admin executive_board at_large_board )

  attr_accessor :stripe_card_token, :subscription

  hstore_accessor :info,
                  stripe_subscription_id: :string,
                  stripe_charge_id: :string,
                  override: :integer

  belongs_to :user

  default_scope -> { where(refunded: nil).order(year: :asc) }
  scope :refunds, -> { unscoped.where.not(refunded: nil).order(year: :asc) }

  before_validation :remove_blank_privileges

  validates :year, presence: true, inclusion: { in: (Date.today.year..Date.today.year+1) }, uniqueness: { scope: [:user_id], conditions: -> { where(refunded: nil) } }
  validates :type, presence: true, inclusion: { in: TYPES, message: 'is not valid' }
  validate :accepted_privileges
  validate :stripe_info_is_unique?
  validate :is_paid_membership

  # Returns *String*. Lists all privileges, comma-separated or in plain english if +verbose+ is true.
  def list_privileges(verbose=false)
    ps = privileges.map(&:titleize)
    if privileges.empty?
      'None'
    elsif verbose
      ps.to_sentence
    else
      ps.join(', ')
    end
  end

  def privileges
    read_attribute(:privileges) || []
  end

  def overriding_admin
    Membership.includes(:user).find_by(users: { id: override }, year: year).try(:user)
  end

  def is_subscription?
    stripe_subscription_id.present?
  end

  # Save with Stripe payment if applicable
  def save_with_payment
    if valid?
      unless overriding_admin || is_a?(Relative)
        customer_params = {
          description: "#{user.first_name} #{user.last_name}",
          email: user.email,
          metadata: {
            first_name: user.first_name,
            last_name: user.last_name,
            address: "#{user.address}\n#{user.city}, #{user.state} #{user.postal_code}",
            phone: user.phone
          }
        }
        if user.stripe_customer_token
          customer = Stripe::Customer.retrieve(user.stripe_customer_token)

          if stripe_card_token || user.email != customer.email
            customer.stripe_card_token = stripe_card_token if stripe_card_token
            customer.email = user.email if user.email != customer.email
            customer.save
          end

          # TODO: Compare generated info w Stripe & update if necessary. This is an estimation.
          # saved_customer_params = Hash[customer.reject{|k,v| !customer_params.keys.include? k.to_sym }.map{|k,v| [k.to_sym, v]}]
          # if saved_customer_params != customer_params
          #   customer.update_attributes(customer_params)
          # end

        else
          customer = Stripe::Customer.create(customer_params.deep_merge(card: stripe_card_token, metadata: { start_year: year }))
          user.stripe_customer_token = customer.id
        end
        if subscription.to_i == 1
          subscription = customer.subscriptions.create(
              plan: type.downcase,
              trial_end: 1.year.from_now.beginning_of_year.to_i
          )
          self.stripe_subscription_id = subscription.id
        end
        charge = Stripe::Charge.create(
            customer: customer.id,
            description: "Midnight Riders #{year} #{type.titleize} Membership",
            metadata: {
                year: year,
                type: type.titleize
            },
            receipt_email: user.email,
            amount: COSTS[type.to_sym],
            currency: 'usd',
            statement_descriptor: "MRiders #{year} #{type.to_s[0..2].titleize} Mem",
        )
        self.stripe_charge_id = charge.id
      end
      save!
    end
  rescue Stripe::StripeError => e
    logger.error "Stripe error while creating customer: #{e.message}"
    errors.add :base, 'There was a problem with your credit card: ' + e.message
    false
  end

  # Cancel current subscription
  def cancel(provide_refund = false)
    if is_subscription?
      stripe_customer.subscriptions.retrieve(stripe_subscription_id).delete
      stripe_subscription_id = nil
      flash[:now][:success] = 'Automatic renewal was successfully canceled.' if save!
      refund if provide_refund
    else
      errors.add :base, 'This is not a recurring subscription.'
    end
  rescue Stripe::StripeError => e
    logger.error "Stripe error while creating customer: #{e.message}"
    errors.add :base, 'There was a problem with your credit card: ' + e.message
    false
  end

  # Refund payment if possible and destroy Membership
  def refund
    if stripe_customer
      if stripe_charge_id
        charge = Stripe::Charge.retrieve(stripe_charge_id)
        refund = charge.refunds.create
        if refund
          refunded = refund.id
        end
      elsif is_subscription?
        if stripe_customer.subscriptions.retrieve(stripe_customer_token).delete
          refunded = 'canceled'
        end
      end
    elsif override
      refunded = 'true'
    else
      logger.error 'There is no Stripe customer'
      errors.add :base, 'No customer token was found on the membership.'
    end
    errors.add :base, 'No action was successfully taken' if refunded.nil?
    save!
  rescue Stripe::StripeError => e
    logger.error "Stripe error while refunding customer: #{e.message}"
    errors.add :base, 'There was a problem refunding the transaction.'
    false
  end

  def stripe_customer
    if user.stripe_customer_token
      Stripe::Customer.retrieve(user.stripe_customer_token)
    else
      nil
    end
  rescue Stripe::InvalidRequestError => e
    logger.error "Stripe::InvalidRequestError: #{e}"
  end

  def info
    if read_attribute(:info).nil?
      {}
    else
      super
    end
  end

  private

    def remove_blank_privileges
      privileges.try(:reject!, &:blank?)
    end

    def accepted_privileges
      errors.add(:privileges, 'include unaccepted values') if privileges && (privileges-PRIVILEGES).present?
    end

    def able_to_change_privileges
      ability = Ability.new(user)
      errors.add(:privileges, 'cannot be changed in this way by this user') if privileges.changed? and ability.cannot?(:grant_privileges, Membership)
    end

    def is_paid_membership
      unless is_a?(Relative)
        errors.add(:base, 'must be paid for') unless info[:stripe_charge_id] || info[:stripe_subscription_id] || stripe_card_token || user.stripe_customer_token || overriding_admin
      end
    end

    def stripe_info_is_unique?
      errors.add(:info, 'contains a redundant Stripe Subscription ID') unless Membership.where.not(id: id).with_stripe_subscription_id(info[:stripe_subscription_id]).empty?
      errors.add(:info, 'contains a redundant Stripe Charge ID') unless Membership.where.not(id: id).with_stripe_charge_id(info[:stripe_charge_id]).empty?
    end
end
