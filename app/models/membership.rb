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
#  privileges :json
#  type       :string
#  created_at :datetime
#  updated_at :datetime
#

class Membership < ActiveRecord::Base
  store_accessor :privileges
  TYPES = %w( Individual Family Relative )
  PRIVILEGES = %w( admin executive_board at_large_board )

  belongs_to :user

  default_scope -> { order('year ASC') }

  before_validation :remove_blank_privileges

  validates :year, presence: true, inclusion: { in: (Date.today.year..Date.today.year+1) }, uniqueness: { scope: :user_id }
  validates :type, presence: true, inclusion: { in: TYPES, message: 'is not valid' }
  validate :accepted_privileges

  # Returns *String*. Lists all privileges, comma-separated or in plain english if +verbose+ is true.
  def list_privileges(verbose=false)
    ps = privileges.map(&:titleize)
    if privileges.empty?
      'None'
    elsif verbose
      ps.to_sentence
    else
      ps.join(', ')
    end
  end

  def privileges
    read_attribute(:privileges) || []
  end

  private

    def remove_blank_privileges
      privileges.try(:reject!, &:blank?)
    end

    def accepted_privileges
      errors.add(:privileges, 'include unaccepted values') if privileges && (privileges-PRIVILEGES).present?
    end

    def able_to_change_privileges
      ability = Ability.new(user)
      errors.add(:privileges, 'cannot be changed in this way by this user') if privileges.changed? and ability.cannot?(:grant_privileges, Membership)
    end
end
