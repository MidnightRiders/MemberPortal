json.array!(@matches) do |match|
  json.extract! match, :id, :home_team_id, :away_team_id, :kickoff, :location, :home_goals, :away_goals
  json.url match_url(match, format: :json)
end
