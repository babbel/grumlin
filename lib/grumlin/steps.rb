# frozen_string_literal: true

module Grumlin
  class Steps
    CONFIGURATION_STEPS = Action::CONFIGURATION_STEPS
    ALL_STEPS = Action::ALL_STEPS

    def self.from(action)
      raise ArgumentError, "expected: #{Action}, given: #{action.class}" unless action.is_a?(Action)

      shortcuts = action.shortcuts
      actions = []

      until action.nil?
        actions.unshift(action)
        action = action.previous_step
      end

      new(shortcuts).tap do |chain|
        actions.each do |act|
          chain.add(act.name, act.arguments)
        end
      end
    end

    attr_reader :configuration_steps, :steps, :shortcuts

    def initialize(shortcuts, configuration_steps: [], steps: [])
      @shortcuts = shortcuts
      @configuration_steps = configuration_steps
      @steps = steps
    end

    def add(name, arguments)
      return add_configuration_step(name, arguments) if CONFIGURATION_STEPS.include?(name)

      StepData.new(name, cast_arguments(arguments)).tap do |step|
        @steps << step
      end
    end

    def uses_shortcuts?
      shortcuts?(@configuration_steps) || shortcuts?(@steps)
    end

    def ==(other)
      self.class == other.class &&
        @shortcuts == other.shortcuts &&
        @configuration_steps == other.configuration_steps &&
        @steps == other.steps
    end

    # TODO: add #bytecode, to_s, inspect

    private

    def shortcuts?(steps_ary)
      steps_ary.any? do |step|
        @shortcuts.include?(step.name) || step.arguments.any? do |arg|
          arg.is_a?(Steps) ? arg.uses_shortcuts? : false
        end
      end
    end

    def add_configuration_step(name, arguments)
      raise ArgumentError, "cannot use configuration steps after start step was used" unless @steps.empty?

      StepData.new(name, cast_arguments(arguments)).tap do |step|
        @configuration_steps << step
      end
    end

    def cast_arguments(arguments)
      arguments.map { |arg| arg.is_a?(Action) ? Steps.from(arg) : arg }
    end
  end
end
