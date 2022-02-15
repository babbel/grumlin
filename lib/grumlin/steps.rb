# frozen_string_literal: true

module Grumlin
  class Steps
    ALL_STEPS = Action::ALL_STEPS

    def self.from(action)
      actions = []

      until action.nil?
        actions.unshift(action)
        action = action.previous_step
      end

      new.tap do |chain|
        actions.each do |act|
          chain.add(act)
        end
      end
    end

    attr_reader :configuration_steps, :steps

    def initialize
      @configuration_steps = []
      @steps = []
    end

    def add(action)
      raise ArgumentError unless action.is_a?(Action)

      return add_configuration_step(action) if action.configuration_step?

      StepData.new(action.name, cast_arguments(action.arguments)).tap do |step|
        @steps << step
      end
    end

    private

    def add_configuration_step(action)
      raise ArgumentError, "cannot use configuration steps after start step was used" unless @steps.empty?

      StepData.new(action.name, cast_arguments(action.arguments)).tap do |step|
        @configuration_steps << step
      end
    end

    def cast_arguments(arguments)
      arguments.map { |arg| arg.is_a?(Action) ? Steps.from(arg) : arg }
    end
  end
end
