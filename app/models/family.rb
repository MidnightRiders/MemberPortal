class Family < Membership
  has_many :relatives

  after_create :re_up_relatives

  private

  def re_up_relatives
    last_membership = user.memberships.where.not(id: id).last
    if last_membership.present? && last_membership.is_a?(Family)
      last_membership.relatives.where("(info->'pending_approval') != ?", 'true').find_each do |relative|
        begin
          new_relative = relative.dup
          new_relative.year = year
          new_relative.family_id = id
          new_relative.save!
        rescue ActiveRecord::RecordInvalid => invalid
          logger.error invalid.record.errors.to_yaml
          logger.info invalid.record.to_yaml
        end
      end
    end
  end
end
