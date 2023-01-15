json.matches do
  json.array!(@matches) do |match|
    json.partial! 'match', match: match
  end
end
json.jwt current_user.jwt
