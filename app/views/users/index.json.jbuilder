json.array!(@users) do |user|
    json.partial! 'users/user_info', user: user
end
