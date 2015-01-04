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
#  created_at :datetime
#  updated_at :datetime
#

class Membership < ActiveRecord::Base
  store_accessor :privileges
  TYPES = %w( Individual Family Relative )
  PRIVILEGES = %w( admin executive_board at_large_board )

  attr_accessor :stripe_card_token

  belongs_to :user

  default_scope -> { where(refunded: nil).order('year ASC') }
  scope :refunded, -> { where.not(refunded: true) }

  before_validation :remove_blank_privileges

  validates :year, presence: true, inclusion: { in: (Date.today.year..Date.today.year+1) }
  validates :type, presence: true, inclusion: { in: TYPES, message: 'is not valid' }
  validate :one_active_membership_per_year
  validate :accepted_privileges
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

  def info
    read_attribute(:info) || []
  end

  def privileges
    read_attribute(:privileges) || []
  end

  def overriding_admin
    Membership.includes(:user).find_by(users: { id: info['override'] }, year: year).try(:user)
  end

  def overridden_memberships
    Membership.includes(:user).where("info -> 'override' = ? AND year = ?", user.id.to_s, year)
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
        end
        info_will_change!
        if info['recurring'].to_i == 1
          subscription = customer.subscriptions.create(
            plan: is_a?(Family) ? '2' : '1',
          )
          info['stripe_subscription_id'] = subscription.id
        else
          charge = Stripe::Charge.create(
            customer: customer.id,
            description: "Midnight Riders #{year} #{type.titleize} Membership",
            metadata: {
              year: year,
              type: type.titleize
            },
            receipt_email: user.email,
            amount: is_a?(Family) ? 2091 : 1061,
            currency: 'usd',
            statement_descriptor: "MRiders #{year} #{type.to_s[0..2].titleize} Mem",
          )
          info['stripe_charge_id'] = charge.id
        end
        user.stripe_customer_token = customer.id
      end
      save!
    end
  rescue Stripe::StripeError => e
    logger.error "Stripe error while creating customer: #{e.message}"
    errors.add :base, 'There was a problem with your credit card: ' + e.message
    false
  end

  # Refund payment if possible and destroy Membership
  def refund
    if user.stripe_customer_token
      if info['stripe_charge_id']
        charge = Stripe::Charge.retrieve(info['stripe_charge_id'])
        refund = charge.refunds.create
        if refund
          update_attribute(:refunded, refund.id)
        end
      elsif info['stripe_subscription_id']
        customer = Stripe::Subscription.retrieve(user.stripe_customer_token)
        if customer.subscriptions.retrieve(info['stripe_subscription_id']).delete
          update_attribute(:refunded, 'canceled')
        end
      end
    elsif info['override']
      update_attribute(:refunded, 'true')
    end
  rescue Stripe::InvalidRequestError => e
    logger.error "Stripe error while refunding customer: #{e.message}"
    errors.add :base, 'There was a problem refunding the transaction.'
    false
  end

  def refund_action(past = false)
    if info['stripe_charge_id']
      "refund#{'ed' if past}"
    elsif info['stripe_subscription_id']
      "cancel#{'ed' if past}"
    elsif info['override']
      "mark#{'ed' if past} as refunded"
    end
  end

  private

    def one_active_membership_per_year
      errors.add(:year, 'already has an active membership') if Membership.unscoped.where(year: year, user_id: user_id).where.not(refunded: nil).size > 0
    end

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
        errors.add(:base, 'must be a paid membership') if info.blank? || !(stripe_card_token || user.stripe_customer_token || overriding_admin)
      end
    end
end
