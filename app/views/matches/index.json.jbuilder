json.start_date @start_date
json.end_date @start_date + 7.days

json.array!(@matches) do |match|
  json.extract! match, :id, :kickoff, :location, :home_goals, :away_goals
  json.home_team match.home_team, :id, :name
  json.away_team match.away_team, :id, :name
  json.url match_url(match, format: :json)
end
