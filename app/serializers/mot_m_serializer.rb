class MotMSerializer < ActiveModel::Serializer
  attributes :id, :match_id, :first_id, :second_id, :third_id

  attribute :links do
    {
      self: scope.mot_m_url(object.match_id),
    }
  end

  attribute :players do
    Player.where(active: true).sort.map { |p| PlayerSerializer.new(p, scope: scope) }
  end
end
