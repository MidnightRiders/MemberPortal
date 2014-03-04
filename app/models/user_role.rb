class UserRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :role

  #load_and_authorize_resource
end
