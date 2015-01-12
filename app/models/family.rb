class Family < Membership
  has_many :relatives

  after_create :re_up_relatives

  private
    def re_up_relatives
      last_membership = user.memberships.where.not(id: id).last
      if last_membership.present? && last_membership.is_a?(Family)
        last_membership.relatives.each do |relative|
          new_relative = relative.clone
          new_relative.year = year
          new_relative.save!
        end
      end
    end
end
