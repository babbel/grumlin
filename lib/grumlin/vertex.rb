# frozen_string_literal: true

class Grumlin::Vertex
  attr_reader :label, :id, :properties

  def initialize(label:, id:, properties: nil)
    @label = label
    @id = Grumlin::Typing.cast(id)
    @properties = properties&.transform_values { |v| Grumlin::Typing.cast(v) }
  end

  def ==(other)
    self.class == other.class && @label == other.label && @id == other.id
  end

  def inspect
    "v[#{@id}]"
  end

  def to_s
    inspect
  end
end
