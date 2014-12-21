# Model belonging to +User+ containing membership information for a given year.
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
  store_accessor :roles
  ROLES = %w( admin executive_board at_large_board individual family )
  PRIVILEGED_ROLES = %w( admin executive_board at_large_board )

  belongs_to :user

  default_scope -> { order('year ASC') }

  before_validation :remove_blank_roles

  validates :year, presence: true, inclusion: { in: (Date.today.year..Date.today.year+1) }
  validates :roles, presence: true
  validate :roles_are_accepted


  # Returns *String*. Lists all roles, comma-separated or in plain english if +verbose+ is true.
  def list_roles(verbose=false)
    rs = roles.map(&:titleize)
    if verbose
      rs.to_sentence
    else
      rs.join(', ')
    end
  end

  def available_roles
    ability = Ability.new(user)
    if ability.can? :manage, User
      ROLES
    else
      ROLES - PRIVILEGED_ROLES
    end
  end

  private

    def remove_blank_roles
      roles.reject!(&:blank?)
    end

    def roles_are_accepted
      unaccepted_roles = (roles-available_roles)
      errors.add(:roles, "does not accept #{unaccepted_roles.map(&:titleize).to_sentence}") if unaccepted_roles.present?
    end

    def able_to_change_roles
      errors.add(:roles, 'cannot be changed in this way by this user') if (roles-available_roles).present?
    end
end
