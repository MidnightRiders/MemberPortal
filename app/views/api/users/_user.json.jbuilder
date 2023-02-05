json.user do
  if current_user.can? :manage, user
    json.extract! user, :id, :username, :first_name, :last_name, :address, :city, :state, :postal_code, :phone, :email, :member_since, :created_at, :updated_at
  else
    json.extract! user, :id, :username, :first_name, :last_name, :member_since
  end
  json.is_current_member user.current_member?
  json.privileges user.current_privileges
  json.gravatar user.gravatar
end
