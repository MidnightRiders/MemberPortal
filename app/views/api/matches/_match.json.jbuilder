json.match do
  return nil if match.nil?

  json.extract! match, :id, :kickoff, :location, :home_goals, :away_goals
  json.home_team do
    json.extract! match.home_team, :id, :name, :abbrv
    json.crest do
      json.thumb match.home_team.crest.url(:thumb)
      json.standard match.home_team.crest.url(:standard)
    end
  end
  json.away_team do
    json.extract! match.away_team, :id, :name, :abbrv
    json.crest do
      json.thumb match.home_team.crest.url(:thumb)
      json.standard match.home_team.crest.url(:standard)
    end
  end
  json.pick_ems do
    json.array! match.pick_ems do |pick_em|
      json.extract! pick_em, :id, :result, :updated_at
      json.user do
        json.extract! pick_em.user, :id, :username, :gravatar
      end
    end
  end
end
