json.array!(@users) do |user|
  json.extract! user, :id, :type_id, :last_name, :first_name, :last_name, :address, :city, :state, :postal_code, :phone, :email, :member_since
  json.url user_url(user, format: :json)
end
