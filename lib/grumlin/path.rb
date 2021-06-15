# frozen_string_literal: true

module Grumlin
  class Path
    def initialize(path)
      @labels = Typing.cast(path[:labels])
      @objects = Typing.cast(path[:objects])
    end
  end
end
