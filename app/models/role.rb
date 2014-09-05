# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Role < ActiveRecord::Base
  has_many :membership_roles, dependent: :destroy
  has_many :memberships, through: :membership_roles
  has_many :users, through: :memberships
  validates :name, uniqueness: true

  # Returns *String*. Lists all roles, comma-separated or in plain english if +verbose+ is true.
  def self.list(verbose=false)
    rs = all.map{|r| r.name.titleize }
    if verbose
      rs.to_sentence
    else
      rs.join(', ')
    end
  end
end
