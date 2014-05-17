class Membership < ActiveRecord::Base
  belongs_to :user

  validates :year, presence: true, inclusion: { in: (Date.today.year..Date.today.year+1) }

end
