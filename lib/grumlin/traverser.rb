# frozen_string_literal: true

module Grumlin
  class Traverser
    attr_reader :bulk, :value

    def initialize(value)
      @bulk = value.dig(:bulk, :@value) || 1
      @value = Typing.cast(value[:value])
    end
  end
end
