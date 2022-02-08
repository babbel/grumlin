# frozen_string_literal: true

module Grumlin
  class Traversal
    SUPPORTED_STEPS = Grumlin.definitions.dig(:steps, :start).map(&:to_sym).freeze

    CONFIGURATION_STEPS = Grumlin.definitions.dig(:steps, :configuration).map(&:to_sym).freeze

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

    CONFIGURATION_STEPS.each do |step|
      define_method step do |*args, **params|
        Action.new(Traversal.new(configuration_steps: @configuration_steps + [Action.new(Step.new(step, *args,
                                                                                                  **params))]))
      end
    end

    SUPPORTED_STEPS.each do |step|
      define_method step do |*args, **params|
        step(step, *args, **params)
      end
    end

    def step(step_name, *args, **params, &block)
      Action.new(Step.new(step_name,
                          *args,
                          configuration_steps: @configuration_steps,
                          **params,
                          &block))
    end
  end
end
