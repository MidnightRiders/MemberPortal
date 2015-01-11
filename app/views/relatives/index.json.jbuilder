json.array!(@user_membership_relatives) do |user_membership_relative|
  json.extract! user_membership_relative, :id
  json.url user_membership_relative_url(user_membership_relative, format: :json)
end
