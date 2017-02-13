# Model belonging to +User+ containing membership information for a given year.
#
class Membership < ActiveRecord::Base
  include Commerce::Purchasable
  include Commerce::Subscribable

  delegate :url_helpers, to: 'Rails.application.routes'

  store_accessor :privileges

  TYPES = %w(Individual Family Relative).freeze
  COSTS = { Individual: '1061', Family: '2091' }.freeze
  PRIVILEGES = %w(admin executive_board at_large_board).freeze

  hstore_accessor :info,
                  override: :integer,
                  pending_approval: :boolean,
                  invited_email: :string

  belongs_to :user

  default_scope -> { where(refunded: nil).order(year: :asc) }
  scope :refunds, -> { unscoped.where.not(refunded: nil).order(year: :asc) }
  scope :current, ->(year = Date.current.year) { includes(:user).where(year: year, refunded: [nil, false]).where.not(user_id: nil) }
  scope :for_year, ->(year = nil) { current(year) }

  before_validation :remove_blank_privileges

  validates :year, presence: true,
    inclusion: {
      in: (Date.current.year..Date.current.year + 1)
    },
    uniqueness: {
      scope: [:user_id], conditions: -> { where(refunded: nil) }
    }
  validates :type, presence: true, inclusion: { in: TYPES, message: 'is not valid' }
  validate :accepted_privileges

  def privileges
    self[:privileges] || []
  end

  def overriding_admin
    return nil unless override.present?
    Membership.includes(:user).find_by(users: { id: override }, year: year)&.user
  end

  def cost
    cost = self.class.price.to_f / 100
    override.present? ? cost.floor : cost
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
    SlackBot.post_message("New #{type} Membership for #{user.first_name} #{user.last_name} " \
      "(<#{url_helpers.user_url(user)}|@#{user.username}>):\n" \
      "*#{year} Total: #{Membership.for_year(year).count}* | #{Membership.breakdown(year)}", 'membership')
  end

  # For +Commerce::Purchasable+
  alias purchaser user

  def previous
    @previous ||= user.memberships.where('year < ?', year).last
  end

  # For Stripe Subscriptions
  def plan
    type.downcase
  end

  # For Stripe Subscriptions
  def trial_end
    1.year.from_now.beginning_of_year.to_i
  end

  def self.breakdown(season = Date.current.year)
    breakdown = for_year(season).group(:year, :type).count
    %w(Individual Family Relative).map { |type| "#{type}: #{breakdown[[season, type]] || 0}" }.join(' | ')
  end

  def self.price
    '1061'
  end

  private

  def paid_for?
    return true if is_a?(Relative) || overriding_admin.present?
    super
  end

  def ready_to_pay?
    !is_a?(Relative) && !overriding_admin && super
  end

  def remove_blank_privileges
    privileges.try(:reject!, &:blank?)
  end

  def accepted_privileges
    errors.add(:privileges, 'include unaccepted values') if privileges && (privileges - PRIVILEGES).present?
  end

  def able_to_change_privileges
    return unless privileges.changed? && user.cannot?(:grant_privileges, Membership)
    errors.add(:privileges, 'cannot be changed in this way by this user')
  end
end
