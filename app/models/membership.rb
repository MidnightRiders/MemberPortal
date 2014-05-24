class Membership < ActiveRecord::Base
  belongs_to :user
  has_many :membership_roles, dependent: :destroy
  has_many :roles, through: :membership_roles

  accepts_nested_attributes_for :roles

  default_scope -> { includes(:roles) }

  validates :year, presence: true, inclusion: { in: (Date.today.year..Date.today.year+1) }

end
