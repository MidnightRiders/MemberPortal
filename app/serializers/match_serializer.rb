class MatchSerializer < ActiveModel::Serializer
  attributes :id, :uri, :home_goals, :away_goals, :kickoff, :location
  belongs_to :home_team, serializer: ClubSerializer
  belongs_to :away_team, serializer: ClubSerializer

  def uri
    scope.match_url(object)
  end

  def kickoff
    object.kickoff.to_f * 1000
  end

  def revs_match?
    object.teams.map(&:abbrv).include? 'NE'
  end

  def current_user?
    scope&.current_user.present?
  end
end
