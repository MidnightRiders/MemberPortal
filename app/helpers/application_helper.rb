module ApplicationHelper
  def revs
    Club.find_by(abbrv: 'NE')
  end
end
