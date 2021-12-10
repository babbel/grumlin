# frozen_string_literal: true

module Grumlin
  class Vertex
    attr_reader :label, :id

    def initialize(label:, id:)
      @label = label
      @id = Typing.cast(id)
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
end
