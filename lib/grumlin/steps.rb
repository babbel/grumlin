# frozen_string_literal: true

class Grumlin::Steps
  CONFIGURATION_STEPS = Grumlin::Step::CONFIGURATION_STEPS
  ALL_STEPS = Grumlin::Step::ALL_STEPS

  def self.from(step)
    raise ArgumentError, "expected: #{Grumlin::Step}, given: #{step.class}" unless step.is_a?(Grumlin::Step)

    new(step.shortcuts).tap do |chain|
      until step.nil? || step.is_a?(Grumlin::TraversalStart)
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
    return add_configuration_step(name, args:, params:, to:) if CONFIGURATION_STEPS.include?(name) || name.to_sym == :tx

    Grumlin::StepData.new(name, args: cast_arguments(args), params:).tap do |step|
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
        arg.is_a?(Grumlin::Steps) ? arg.uses_shortcuts? : false
      end
    end
  end

  def add_configuration_step(name, args: [], params: {}, to: :end)
    raise ArgumentError, "cannot use configuration steps after start step was used" if @steps.any? && to == :end

    Grumlin::StepData.new(name, args: cast_arguments(args), params:).tap do |step|
      next @configuration_steps << step if to == :end
      next @configuration_steps.unshift(step) if to == :begin

      raise ArgumentError, "to must be either :begin or :end, given: '#{to}'"
    end
  end

  def cast_arguments(arguments)
    arguments.map { |arg| arg.is_a?(Grumlin::Step) ? Grumlin::Steps.from(arg) : arg }
  end
end
