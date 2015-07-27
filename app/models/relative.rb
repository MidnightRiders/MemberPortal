class Relative < Membership
  belongs_to :family
  accepts_nested_attributes_for :user

  validate :has_good_family
  validate :no_time_traveling

  private

    def has_good_family
      errors.add(:family_id, 'must have a family association') if family_id.nil?
      errors.add(:family_id, 'is not a valid family membership') unless family_id.nil? || family.is_a?(Family)
    end

    def no_time_traveling
      errors.add(:year, 'is not the same year as family membership') if year != family.try(:year)
    end
end
