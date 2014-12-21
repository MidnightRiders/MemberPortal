if can? :manage, user
    json.extract! user, :id, :username, :first_name, :last_name, :address, :city, :state, :postal_code, :phone, :email, :member_since, :created_at, :updated_at
else
    json.extract! user, :id, :username, :first_name, :last_name, :member_since, :created_at, :updated_at
end
json.current_privileges user.current_privileges
json.url user_url(user)