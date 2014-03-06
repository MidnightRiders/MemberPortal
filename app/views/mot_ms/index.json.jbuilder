json.array!(@mot_ms) do |mot_m|
  json.extract! mot_m, :id, :user_id, :match_id, :first_id, :second_id, :third_id
  json.url mot_m_url(mot_m, format: :json)
end
