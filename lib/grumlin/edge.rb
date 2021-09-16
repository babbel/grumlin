# frozen_string_literal: true

module Grumlin
  class Edge
    attr_reader :label, :id, :inVLabel, :outVLabel, :inV, :outV

    def initialize(label:, id:, inVLabel:, outVLabel:, inV:, outV:)
      @label = label
      @id = Typing.cast(id)
      @inVLabel = inVLabel
      @outVLabel = outVLabel
      @inV = Typing.cast(inV)
      @outV = Typing.cast(outV)
    end

    def ==(other)
      self.class == other.class && @label == other.label && @id == other.id
    end

    def inspect
      "e[#{@id}][#{@outV}-#{@label}->#{@inV}]"
    end
    alias to_s inspect
  end
end
