# frozen_string_literal: true

module Grumlin
  class Path
    attr_reader :objects

    def initialize(path)
      @labels = Typing.cast(path[:labels])
      @objects = Typing.cast(path[:objects])
    end

    def inspect
      "p[#{@objects}]"
    end
    alias to_s inspect
  end
end
