class MatchSerializer < ActiveModel::Serializer
  attributes :id, :home_goals, :away_goals, :location, :mot_m, :rev_guess
  belongs_to :home_team, serializer: ClubSerializer
  belongs_to :away_team, serializer: ClubSerializer

  attribute :uri do
    scope.match_url(object)
  end

  attribute :kickoff do
    object.kickoff.to_f * 1000
  end

  attribute :pick do
    instance_options[:pick]&.result_key
  end

  def rev_guess
    return nil unless revs_match?
    rev_guess = scope.current_user.rev_guesses.find_by(match_id: object.id)
    ActiveModelSerializers::SerializableResource.new(rev_guess, scope: scope) if rev_guess
  end

  def mot_m
    return nil unless revs_match?
    mot_m = scope.current_user.mot_ms.find_by(match_id: object.id)
    ActiveModelSerializers::SerializableResource.new(mot_m, scope: scope) if mot_m
  end

  private

  def revs_match?
    object.teams.map(&:abbrv).include? 'NE'
  end

  def current_user?
    scope&.current_user.present?
  end
end
