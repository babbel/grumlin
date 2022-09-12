# frozen_string_literal: true

class Grumlin::Traverser
  attr_reader :bulk, :value

  def initialize(value)
    @bulk = value.dig(:bulk, :@value) || 1
    @value = Grumlin::Typing.cast(value[:value])
  end
end
