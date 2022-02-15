# frozen_string_literal: true

module Grumlin
  class StepData
    attr_reader :name, :arguments

    def initialize(name, arguments)
      @name = name
      @arguments = arguments
    end

    def ==(other)
      self.class == other.class &&
        @name == other.name &&
        @arguments == other.arguments
    end
  end
end
