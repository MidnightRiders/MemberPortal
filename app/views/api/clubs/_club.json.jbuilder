json.club do
  json.extract! club, :id, :name, :abbrv, :conference
  json.colors do
    json.primary club.primary_color
    json.secondary club.secondary_color
    json.accent club.accent_color
  end
  json.record do
    json.extract! club.record, :wins, :losses, :draws
  end
end
