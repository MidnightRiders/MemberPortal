class Match < ActiveRecord::Base
  belongs_to :home_team, class_name: 'Club'
  belongs_to :away_team, class_name: 'Club'

  has_many :mot_ms

  validates :home_team, :away_team, :kickoff, :location, presence: true
  validates :uid, uniqueness: { case_sensitive: true, allow_blank: true }

  def score
    if home_goals.blank? && away_goals.blank?
      '—'
    else
      "#{home_goals || 0} – #{away_goals || 0}"
    end
  end

  def voteable?
    kickoff && Time.now > kickoff + 45.minutes
  end

end
