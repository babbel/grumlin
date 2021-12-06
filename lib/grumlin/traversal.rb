# frozen_string_literal: true

module Grumlin
  class Traversal
    # TODO: add other start steps
    SUPPORTED_STEPS = %i[E V addE addV].freeze

    CONFIGURATION_STEPS = %i[withSideEffect].freeze

    def initialize(pool = Grumlin.default_pool, configuration_steps: [])
      @pool = pool
      @configuration_steps = configuration_steps
    end

    CONFIGURATION_STEPS.each do |step|
      define_method step do |*args|
        self.class.new(@pool, configuration_steps: @configuration_steps + [AnonymousStep.new(step, *args)])
      end
    end

    SUPPORTED_STEPS.each do |step|
      define_method step do |*args|
        Step.new(@pool, step, *args, configuration_steps: @configuration_steps)
      end
    end
  end
end
