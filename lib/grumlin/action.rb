# frozen_string_literal: true

module Grumlin
  class Action
    extend Forwardable

    START_STEPS = Grumlin.definitions.dig(:steps, :start).map(&:to_sym).freeze # TODO: add validation
    CONFIGURATION_STEPS = Grumlin.definitions.dig(:steps, :configuration).map(&:to_sym).freeze # TODO: add validation

    SUPPORTED_STEPS = Grumlin.definitions.dig(:steps, :regular).map(&:to_sym).freeze

    attr_reader :action_step, :shortcuts, :start_step, :next_step, :configuration_steps

    def initialize(step, start_step: nil, shortcuts: {},
                   configuration_steps: [], context: nil, pool: Grumlin.default_pool)
      @action_step = step

      @start_step = start_step || self if step.is_a?(Step)

      @configuration_steps = configuration_steps

      @shortcuts = shortcuts
      @context = context
      @pool = pool
    end

    START_STEPS.each do |step|
      define_method step do |*args, **params|
        step(step, *args, **params)
      end
    end

    CONFIGURATION_STEPS.each do |step|
      define_method step do |*args, **params|
        configuration_steps = @configuration_steps + [Action.new(Step.new(step, *args, **params))]
        @next_step = Action.new(Traversal.new, shortcuts: @shortcuts, context: @context, pool: @pool,
                                               configuration_steps: configuration_steps, start_step: @start_step)
      end
    end

    SUPPORTED_STEPS.each do |step|
      define_method(step) do |*args, **params|
        step(step, *args, **params)
      end
    end

    def step(step_name, *args, **params)
      @next_step = wrap_result(Step.new(step_name, *args, **params))
    end

    def method_missing(name, *args, **params)
      # TODO: remove unused cases
      return wrap_result(@context.public_send(name, *args, **params)) if name == :__ && !@context.nil?

      return wrap_result(@action_step.public_send(name, *args, **params)) if @action_step.respond_to?(name)

      if @shortcuts.key?(name)
        result = @shortcuts[name].apply(self, *args, **params)
        return @next_step || wrap_result(result)
      end

      super
    end

    def to_s
      inspect
    end

    # TODO: add support for inspecting __ and g from Sugar
    def inspect
      bytecode.inspect
    end

    def bytecode(no_return: false)
      @bytecode ||= Bytecode.new(self, no_return: no_return)
    end

    def next
      to_enum.next
    end

    def hasNext # rubocop:disable Naming/MethodName
      to_enum.peek
      true
    rescue StopIteration
      false
    end

    def to_enum
      @to_enum ||= toList.to_enum
    end

    def toList
      @pool.acquire do |client|
        client.write(bytecode)
      end
    end

    def iterate
      @pool.acquire do |client|
        client.write(bytecode(no_return: true))
      end
    end

    private

    def respond_to_missing?(name, include_private = false)
      name = name.to_sym

      (%i[__].include?(name) &&
        @context.respond_to?(name, include_private)) ||
        @action_step.respond_to?(name, include_private) ||
        @shortcuts.key?(name) ||
        super
    end

    def wrap_result(result)
      if result.is_a?(Action)
        return Action.new(result.action_step, shortcuts: @shortcuts,
                                              context: @context,
                                              pool: @pool,
                                              configuration_steps: @configuration_steps,
                                              start_step: @start_step)
      end

      if result.is_a?(Step) || result.is_a?(Traversal)
        return Action.new(result, shortcuts: @shortcuts, context: @context, pool: @pool,
                                  configuration_steps: @configuration_steps, start_step: @start_step)
      end

      result
    end
  end
end
