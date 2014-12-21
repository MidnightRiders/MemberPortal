class Relative < Membership
  belongs_to :family

  validates_associated :family
end
