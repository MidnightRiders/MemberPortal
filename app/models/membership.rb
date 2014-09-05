# Model belonging to +User+ containing membership information for a given year.
# Has many +Roles+ that describe the +User+'s abilities within that scope.
#
# == Schema Information
#
# Table name: memberships
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  year       :integer
#  info       :hstore
#  created_at :datetime
#  updated_at :datetime
#

class Membership < ActiveRecord::Base
  belongs_to :user
  has_many :membership_roles, dependent: :destroy
  has_many :roles, through: :membership_roles

  accepts_nested_attributes_for :roles

  default_scope -> { includes(:roles) }

  validates :year, presence: true, inclusion: { in: (Date.today.year..Date.today.year+1) }

end
