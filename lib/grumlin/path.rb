# frozen_string_literal: true

class Grumlin::Path
  attr_reader :objects

  def initialize(path)
    @labels = Grumlin::Typing.cast(path[:labels])
    @objects = Grumlin::Typing.cast(path[:objects])
  end

  def inspect
    "p[#{@objects}]"
  end

  def to_s
    inspect
  end
end
