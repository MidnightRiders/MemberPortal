class MotM < ActiveRecord::Base
  validates :user, :match, :first_id, associated: true, presence: true
  validates :second_id, :third_id, associated: true, allow_nil: true

end
