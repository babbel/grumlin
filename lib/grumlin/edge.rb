# frozen_string_literal: true

class Grumlin::Edge
  attr_reader :label, :id, :inVLabel, :outVLabel, :inV, :outV

  def initialize(label:, id:, inVLabel:, outVLabel:, inV:, outV:)
    @label = label
    @id = Grumlin::Typing.cast(id)
    @inVLabel = inVLabel
    @outVLabel = outVLabel
    @inV = Grumlin::Typing.cast(inV)
    @outV = Grumlin::Typing.cast(outV)
  end

  def ==(other)
    self.class == other.class && @label == other.label && @id == other.id
  end

  def inspect
    "e[#{@id}][#{@outV}-#{@label}->#{@inV}]"
  end

  def to_s
    inspect
  end
end
