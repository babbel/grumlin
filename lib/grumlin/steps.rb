# frozen_string_literal: true

module Grumlin
  class Steps
    CONFIGURATION_STEPS = Step::CONFIGURATION_STEPS
    ALL_STEPS = Step::ALL_STEPS

    def self.from(step)
      raise ArgumentError, "expected: #{Step}, given: #{step.class}" unless step.is_a?(Step)

      new(step.shortcuts).tap do |chain|
        until step.nil? || step.is_a?(TraversalStart)
          chain.add(step.name, args: step.args, params: step.params, to: :begin)
          step = step.previous_step
        end
      end
    end

    attr_reader :configuration_steps, :steps, :shortcuts

    def initialize(shortcuts, configuration_steps: [], steps: [])
      @shortcuts = shortcuts
      @configuration_steps = configuration_steps
      @steps = steps
    end

    def add(name, args: [], params: {}, to: :end)
      if CONFIGURATION_STEPS.include?(name) || name.to_sym == :tx
        return add_configuration_step(name, args: args, params: params, to: to)
      end

      StepData.new(name, args: cast_arguments(args), params: params).tap do |step|
        next @steps << step if to == :end
        next @steps.unshift(step) if to == :begin

        raise ArgumentError, "'to:' must be either :begin or :end, given: '#{to}'"
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
        @shortcuts.known?(step.name) || step.args.any? do |arg|
          arg.is_a?(Steps) ? arg.uses_shortcuts? : false
        end
      end
    end

    def add_configuration_step(name, args: [], params: {}, to: :end)
      raise ArgumentError, "cannot use configuration steps after start step was used" if @steps.any? && to == :end

      StepData.new(name, args: cast_arguments(args), params: params).tap do |step|
        next @configuration_steps << step if to == :end
        next @configuration_steps.unshift(step) if to == :begin

        raise ArgumentError, "to must be either :begin or :end, given: '#{to}'"
      end
    end

    def cast_arguments(arguments)
      arguments.map { |arg| arg.is_a?(Step) ? Steps.from(arg) : arg }
    end
  end
end
