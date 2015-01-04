class Relative < Membership
  belongs_to :family
  accepts_nested_attributes_for :user

  validates_associated :family
end
