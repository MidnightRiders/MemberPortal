json.array!(@clubs) do |club|
  json.extract! club, :id, :name, :conference, :primary_color, :secondary_color, :accent_color, :abbrv
  json.url club_url(club, format: :json)
end
