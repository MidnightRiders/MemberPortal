class Match < ActiveRecord::Base
  belongs_to :home_team, class_name: 'Club'
  belongs_to :away_team, class_name: 'Club'

  has_many :mot_ms

  validates :home_team_id, :away_team_id, :kickoff, :location, presence: true
  validate :has_both_teams

  private
    def has_both_teams
      !home_team.name.nil? && !away_team.name.nil?
    end
end
