class Role < ActiveRecord::Base
  has_many :membership_roles, dependent: :destroy
  has_many :memberships, through: :membership_roles
  has_many :users, through: :memberships
  validates :name, uniqueness: true

  def self.list(verbose=false)
    rs = all.map{|r| r.name.titleize }
    if verbose
      rs.to_sentence
    else
      rs.join(', ')
    end
  end
end
