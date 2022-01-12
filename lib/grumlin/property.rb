# frozen_string_literal: true

module Grumlin
  class Property
    attr_reader :key, :value

    def initialize(value)
      @key = value[:key]
      @value = Typing.cast(value[:value])
    end

    def inspect
      "p[#{key}->#{value}]"
    end

    def to_s
      inspect
    end
  end
end
