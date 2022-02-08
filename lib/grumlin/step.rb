# frozen_string_literal: true

module Grumlin
  class Step
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

    def args
      [*@args].tap do |args|
        args << @params if @params.any?
      end
    end

    def step(step_name, *args, **params)
      @next_step = Step.new(step_name, *args, first_step: @first_step, **params)
    end
  end
end
