# Application-wide helper module.
module ApplicationHelper

  # Returns *ActiveRecord Object* for the Revolution.
  def revs
    Club.includes(:home_matches,:away_matches).find_by(abbrv: 'NE')
  end
end
