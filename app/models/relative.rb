class Relative < Membership
  belongs_to :family
  accepts_nested_attributes_for :user

  before_validation :strip_invited_email

  validate :has_good_family
  validate :no_time_traveling

  scope :approved, -> { where("info->'pending_approval'::text != ?", 'true') }
  scope :pending, -> { where("info->'pending_approval'::text = ?", 'true') }

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

  private

  def strip_invited_email
    info.dig(:invited_email)&.strip!
  end

  def has_good_family
    errors.add(:family_id, 'must have a family association') if family_id.nil?
    errors.add(:family_id, 'is not a valid family membership') unless family_id.nil? || family.is_a?(Family)
  end

  def no_time_traveling
    errors.add(:year, 'is not the same year as family membership') if year != family.try(:year)
  end

  def notify_slack
    SlackBot.post_message("#{user.first_name} #{user.last_name} (<#{user_url(user)}|@#{user.username}>) has accepted *#{family.user.first_name} #{family.user.last_name}’s Family Membership invitation*:\nThere are now *#{for_year(year).size} registered #{year} Memberships.*\n#{Membership.breakdown(year)}", 'membership')
  end
end
