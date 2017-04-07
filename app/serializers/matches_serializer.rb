class MatchesSerializer < ActiveModel::Serializer
  attribute :matches do
    object.map { |m| serialize(m) }
  end

  attribute :mot_m do
    MotMSerializer.new(instance_options[:mot_m], scope: scope) if instance_options[:mot_m].present?
  end

  attribute :rev_guess do
    RevGuessSerializer.new(instance_options[:rev_guess], scope: scope) if instance_options[:rev_guess].present?
  end

  private

  def serialize(obj)
    ActiveModel::SerializableResource.new(obj, scope: scope)
  end
end
