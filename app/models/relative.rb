class Relative < Membership
  belongs_to :family
  accepts_nested_attributes_for :user

  before_validation :strip_invited_email

  hstore_accessor :info,
                  pending_approval: :boolean,
                  invited_email: :string

  validate :has_good_family
  validate :no_time_traveling
  validate :valid_invited_email

  scope :approved, -> { not_pending_approval }
  scope :pending, -> { is_pending_approval }

  def relatives
    [family] + family.relatives - [self]
  end

  def re_up_for(year = Date.current.year)
    new_relative = dup
    new_relative.year = year
    new_relative.family_id = id
    new_relative.save!
    new_relative
  rescue ActiveRecord::RecordInvalid => invalid
    logger.error invalid.record.errors.to_yaml
    logger.info invalid.record.to_yaml
  end

  def notify_slack
    SlackBot.post_message("#{user.first_name} #{user.last_name} (<#{url_helpers.user_url(user)}|@#{user.username}>) has accepted *#{family.user.first_name} #{family.user.last_name}’s Family Membership invitation*:\nThere are now *#{Membership.for_year(year).size} registered #{year} Memberships.*\n#{Membership.breakdown(year)}", 'membership')
  end

  def self.price
    nil
  end

  private

  def paid_for?
    true
  end

  def strip_invited_email
    invited_email&.strip!
  end

  def has_good_family
    errors.add(:family_id, 'must have a family association') if family_id.nil?
    errors.add(:family_id, 'is not a valid family membership') unless family_id.nil? || family.is_a?(Family)
  end

  def no_time_traveling
    return unless family.present?
    errors.add(:year, 'is not the same year as family membership') if year != family&.year
  end

  def valid_invited_email
    errors[:info] = (errors[:info] || {}).merge(invited_email: 'does not appear to be valid') unless Devise.email_regexp =~ invited_email
  end
end
