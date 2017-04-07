class PickEmSerializer < ActiveModel::Serializer
  attributes :id, :match_id, :result

  attr :links do
    {
      self: scope.pick_em_url(object.match_id)
    }
  end
end
