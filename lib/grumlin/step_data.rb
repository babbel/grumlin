# frozen_string_literal: true

module Grumlin
  class StepData
    attr_reader :name, :args, :params

    def initialize(name, args: [], params: {})
      @name = name
      @args = args
      @params = params
    end

    def ==(other)
      self.class == other.class &&
        @name == other.name &&
        @args == other.args &&
        @params == other.params
    end
  end
end
