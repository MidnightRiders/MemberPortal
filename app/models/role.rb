class Role < ActiveRecord::Base
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles
  has_many :membership_roles, dependent: :destroy
  has_many :memberships, through: :membership_roles
  validates :name, uniqueness: true
end
