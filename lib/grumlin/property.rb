# frozen_string_literal: true

class Grumlin::Property
  attr_reader :key, :value

  def initialize(value)
    @key = value[:key]
    @value = Grumlin::Typing.cast(value[:value])
  end

  def inspect
    "p[#{key}->#{value}]"
  end

  def to_s
    inspect
  end

  def ==(other)
    self.class == other.class && @key == other.key && @value == other.value
  end
end
