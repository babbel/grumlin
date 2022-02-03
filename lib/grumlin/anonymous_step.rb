# frozen_string_literal: true

module Grumlin
  class AnonymousStep
    attr_reader :name, :first_step, :next_step

    SUPPORTED_STEPS = Grumlin.definitions.dig(:steps, :regular).map(&:to_sym).freeze

    def initialize(name, *args, configuration_steps: [], first_step: nil, **params)
      @name = name
      @args = args
      @params = params

      @first_step = first_step || self
      @configuration_steps = configuration_steps if first_step.nil?

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

    def step(name, *args, **params)
      @next_step = self.class.new(name, *args, first_step: @first_step, **params)
    end

    def inspect
      bytecode.inspect
    end

    def to_s
      inspect
    end

    def bytecode(no_return: false)
      @bytecode ||= Bytecode.new(self, no_return: no_return)
    end

    def args
      [*@args].tap do |args|
        args << @params if @params.any?
      end
    end
  end
end
