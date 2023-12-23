json.array!(@full_user_set) do |user|
  json.partial! 'users/user_info', user: user
end
