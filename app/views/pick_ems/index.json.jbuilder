json.array!(@pick_ems) do |pick_em|
  json.extract! pick_em, :id, :match_id, :user_id, :result
  json.url pick_em_url(pick_em, format: :json)
end
