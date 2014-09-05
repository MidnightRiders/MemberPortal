# Connector model from +Memberships+ to +Roles+.
#
# == Schema Information
#
# Table name: membership_roles
#
#  id            :integer          not null, primary key
#  membership_id :integer
#  role_id       :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class MembershipRole < ActiveRecord::Base
  belongs_to :membership
  belongs_to :role
end
