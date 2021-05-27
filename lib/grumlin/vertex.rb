# frozen_string_literal: true

module Grumlin
  class Vertex
    attr_reader :label, :id

    def initialize(label:, id:)
      @label = label
      @id = Typing.cast(id)
    end

    def ==(other)
      @label == other.label && @id == other.id
    end

    def inspect
      "<V #{@label}(#{@id})>"
    end
    alias to_s inspect
  end
end
