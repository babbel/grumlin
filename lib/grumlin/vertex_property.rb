# frozen_string_literal: true

module Grumlin
  class VertexProperty
    attr_reader :label, :value

    def initialize(value)
      @label = value[:label]
      @value = Typing.cast(value[:value])
    end

    def inspect
      "vp[#{label}->#{value}]"
    end

    def to_s
      inspect
    end

    def ==(other)
      self.class == other.class && @label == other.label && @value == other.value
    end
  end
end
