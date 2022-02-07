# frozen_string_literal: true

module Grumlin
  class Step
    attr_reader :name, :first_step, :next_step, :block

    SUPPORTED_STEPS = Grumlin.definitions.dig(:steps, :regular).map(&:to_sym).freeze

    # if block is passed, it will be lazily evaluated in #next_step
    def initialize(name, *args, configuration_steps: [], first_step: nil, **params, &block)
      @name = name
      @args = args
      @params = params

      @first_step = first_step || self
      @configuration_steps = configuration_steps if first_step.nil?

      @block = block

      @next_step = nil
    end

    SUPPORTED_STEPS.each do |step|
      define_method(step) do |*args, **params|
        step(step, *args, **params)
      end
    end

    def configuration_steps
      @configuration_steps || @first_step.configuration_steps
    end

    def shortcut?
      !@block.nil?
    end

    # TODO: remove
    def to_s
      inspect
    end

    # TODO: remove
    def inspect
      bytecode.inspect
    end

    # TODO: remove
    def bytecode(no_return: false)
      @bytecode ||= Bytecode.new(self, no_return: no_return)
    end

    def args
      [*@args].tap do |args|
        args << @params if @params.any?
      end
    end

    def step(step_name, *args, **params, &block)
      @next_step = self.class.new(step_name, *args, first_step: @first_step, **params, &block)
    end
  end
end
