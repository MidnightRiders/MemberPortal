module ApplicationHelper
  def revs
    Club.includes(:home_matches,:away_matches).find_by(abbrv: 'NE')
  end
end
