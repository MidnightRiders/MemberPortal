# Helper for +Membership+ model.
module MembershipsHelper
  def greatest_membership_year
    Date.current.month > 10 ? Date.current.year + 1 : Date.current.year
  end
end
