class MatchSerializer < ActiveModel::Serializer
  attributes :id, :home_goals, :away_goals, :kickoff, :location
  attribute :pick, if: :current_user?
  belongs_to :home_team, serializer: ClubSerializer
  belongs_to :away_team, serializer: ClubSerializer

  def pick
    scope&.current_user&.pick_for(object)&.result_key
  end

  def mot_m
    return unless object.voteable? && scope&.current_user
    object.mot_ms.find_by(user_id: scope.current_user.id)
  end

  def rev_guess
    return unless object.revs? && object.in_future? && scope&.current_user
    object.rev_guesses.find_by(user_id: scope.current_user.id)
  end

  def kickoff
    object.kickoff.to_f * 1000
  end

  def current_user?
    scope&.current_user.present?
  end
end
