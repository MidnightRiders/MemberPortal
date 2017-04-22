class MatchesSerializer < ActiveModel::Serializer
  attribute :matches do
    pick_ems = scope.current_user.pick_ems.where(match_id: object.map(&:id)).map { |p| [p.match_id, p] }.to_h
    object.map { |m| serialize(m, pick: pick_ems[m.id]) }
  end

  attribute :mot_m do
    serialize(instance_options[:mot_m]) if instance_options[:mot_m].present?
  end

  attribute :rev_guess do
    serialize(instance_options[:rev_guess]) if instance_options[:rev_guess].present?
  end

  private

  def serialize(obj, args = {})
    args[:scope] = scope
    ActiveModelSerializers::SerializableResource.new(obj, args)
  end
end
