class RevGuessSerializer < ActiveModel::Serializer
  attributes :id, :match_id, :home_goals, :away_goals, :comment

  attribute :links do
    {
      self: scope.rev_guess_url(object.match_id)
    }
  end
end
