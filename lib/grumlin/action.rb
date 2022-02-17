# frozen_string_literal: true

module Grumlin
  class Action
    START_STEPS = Grumlin.definitions.dig(:steps, :start).map(&:to_sym).freeze # TODO: add validation
    CONFIGURATION_STEPS = Grumlin.definitions.dig(:steps, :configuration).map(&:to_sym).freeze # TODO: add validation
    REGULAR_STEPS = Grumlin.definitions.dig(:steps, :regular).map(&:to_sym).freeze

    ALL_STEPS = START_STEPS + CONFIGURATION_STEPS + REGULAR_STEPS

    attr_reader :name, :args, :params, :shortcuts, :next_step, :configuration_steps, :previous_step

    def initialize(name, args: [], params: {}, previous_step: nil, shortcuts: {}, pool: Grumlin.default_pool)
      @name = name.to_sym
      @args = args # TODO: add recursive validation: only json types or Action
      @params = params # TODO: add recursive validation: only json types
      @previous_step = previous_step
      @shortcuts = shortcuts
      @pool = pool
    end

    ALL_STEPS.each do |step|
      define_method step do |*args, **params|
        step(step, *args, **params)
      end
    end

    def step(name, *args, **params)
      Action.new(name, args: args, params: params, previous_step: self, shortcuts: @shortcuts, pool: @pool)
    end

    def configuration_step?
      CONFIGURATION_STEPS.include?(@name)
    end

    def start_step?
      START_STEPS.include?(@name)
    end

    def regular_step?
      REGULAR_STEPS.include?(@name)
    end

    def supported_step?
      ALL_STEPS.include?(@name)
    end

    def shortcut?
      @shortcuts.key?(@name)
    end

    def arguments
      @arguments ||= [*@args].tap do |args|
        args << @params if @params.any?
      end
    end

    def method_missing(name, *args, **params)
      return step(name, *args, **params) if @shortcuts.key?(name)

      super
    end

    def ==(other)
      self.class == other.class &&
        @name == other.name &&
        @args == other.args &&
        @params == other.params &&
        @previous_step == other.previous_step &&
        @shortcuts == other.shortcuts
    end

    def steps
      @steps ||= Steps.from(self)
    end
    # TODO: add #bytecode

    private

    def respond_to_missing?(name, _include_private = false)
      @shortcuts.key?(name)
    end
  end
end
