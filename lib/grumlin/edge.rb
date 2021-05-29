# frozen_string_literal: true

# rubocop:disable Naming/VariableName,Naming/MethodParameterName,Naming/MethodName
module Grumlin
  class Edge
    attr_reader :label, :id, :inVLabel, :outVLabel, :inV, :outV

    def initialize(label:, id:, inVLabel:, outVLabel:, inV:, outV:) # rubocop:disable Metrics/ParameterLists
      @label = label
      @id = Typing.cast(id)
      @inVLabel = inVLabel
      @outVLabel = outVLabel
      @inV = Typing.cast(inV)
      @outV = Typing.cast(outV)
    end

    def ==(other)
      @label == other.label && @id == other.id
    end

    def inspect
      "e[#{@id}][#{@inV}-#{@label}->#{@outV}]"
    end
    alias to_s inspect
  end
end
# rubocop:enable Naming/MethodParameterName,Naming/VariableName,Naming/MethodName
