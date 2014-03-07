json.array!(@rev_guesses) do |rev_guess|
  json.extract! rev_guess, :id, :match_id, :user_id, :home_goals, :away_goals, :comment
  json.url rev_guess_url(rev_guess, format: :json)
end
