# frozen_string_literal: true

module Grumlin
  class TraversalStart
    extend Forwardable

    START_STEPS = Grumlin.definitions.dig(:steps, :start).map(&:to_sym).freeze
    REGULAR_STEPS = Grumlin.definitions.dig(:steps, :regular).map(&:to_sym).freeze
    CONFIGURATION_STEPS = Grumlin.definitions.dig(:steps, :configuration).map(&:to_sym).freeze

    ALL_STEPS = START_STEPS + CONFIGURATION_STEPS + REGULAR_STEPS

    ALL_STEPS.each do |step|
      define_method step do |*args, **params|
        step(step, *args, **params)
      end
    end

    attr_reader :shortcuts

    def initialize(shortcuts)
      @shortcuts = shortcuts
    end

    def step(name, *args, **params)
      @shortcuts.action_class.new(name, args: args, params: params, shortcuts: @shortcuts)
    end

    def_delegator :@shortcuts, :__

    def to_s(*)
      self.class.to_s
    end

    def inspect
      self.class.inspect
    end
  end
end
