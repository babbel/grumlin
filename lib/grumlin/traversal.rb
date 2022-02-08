# frozen_string_literal: true

module Grumlin
  class Traversal
    attr_reader :configuration_steps

    # TODO: move configuration steps handling to Action
    def initialize(configuration_steps: [])
      @configuration_steps = configuration_steps
    end

    def inspect
      "#<#{self.class}>"
    end

    def to_s
      inspect
    end
  end
end
