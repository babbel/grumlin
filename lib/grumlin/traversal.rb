# frozen_string_literal: true

module Grumlin
  class Traversal
    # TODO: add other start steps
    SUPPORTED_STEPS = %i[E V addE addV].freeze

    CONFIGURATION_STEPS = %i[withSideEffect].freeze

    attr_reader :configuration_steps

    def initialize(pool = Grumlin.default_pool, configuration_steps: [])
      @pool = pool
      @configuration_steps = configuration_steps
    end

    alias inspect to_s

    CONFIGURATION_STEPS.each do |step|
      define_method step do |*args, **params|
        self.class.new(@pool, configuration_steps: @configuration_steps + [AnonymousStep.new(step, *args, **params)])
      end
    end

    SUPPORTED_STEPS.each do |step|
      define_method step do |*args, **params|
        Step.new(@pool, step, *args, configuration_steps: @configuration_steps, **params)
      end
    end
  end
end
