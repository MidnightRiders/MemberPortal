json.array!(@players) do |player|
  json.extract! player, :id, :first_name, :last_name, :club_id, :position
  json.url player_url(player, format: :json)
end
