json.clubs do
  json.array!(@clubs) do |club|
    json.partial! 'club', club: club
  end
end
json.jwt current_user.jwt
