class Membership < ActiveRecord::Base
  belongs_to :user
  has_many :membership_roles, dependent: :destroy
  has_many :roles, through: :membership_roles

  validates :year, presence: true, inclusion: { in: (Date.today.year..Date.today.year+1) }

end
