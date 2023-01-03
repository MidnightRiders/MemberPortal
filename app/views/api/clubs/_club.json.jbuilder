json.club do
  json.extract! club, :id, :name, :abbrv, :conference
  json.colors do
    json.primary club.primary_color
    json.secondary club.secondary_color
    json.accent club.accent_color
  end
  json.crest do
    json.thumb club.crest.url(:thumb)
    json.standard club.crest.url(:standard)
  end
  json.record do
    json.extract! club, :wins, :losses, :draws
  end
end
json.jwt current_user.jwt
