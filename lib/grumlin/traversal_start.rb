# frozen_string_literal: true

module Grumlin
  class TraversalStart
    START_STEPS = Grumlin.definitions.dig(:steps, :start).map(&:to_sym).freeze
    REGULAR_STEPS = Grumlin.definitions.dig(:steps, :regular).map(&:to_sym).freeze
    CONFIGURATION_STEPS = Grumlin.definitions.dig(:steps, :configuration).map(&:to_sym).freeze

    ALL_STEPS = START_STEPS + CONFIGURATION_STEPS + REGULAR_STEPS

    ALL_STEPS.each do |step|
      define_method step do |*args, **params|
        step(step, *args, **params)
      end
    end

    def initialize(shortcuts)
      @shortcuts = shortcuts
    end

    def step(name, *args, **params)
      Action.new(name, args: args, params: params, shortcuts: @shortcuts)
    end

    def method_missing(name, *args, **params)
      return step(name, *args, **params) if @shortcuts.key?(name)

      super
    end

    private

    def respond_to_missing?(name, _include_private = false)
      @shortcuts.key?(name)
    end
  end
end
