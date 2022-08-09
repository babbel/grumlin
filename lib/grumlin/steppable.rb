# frozen_string_literal: true

module Grumlin
  class Steppable
    extend Forwardable

    START_STEPS = Grumlin.definitions.dig(:steps, :start).map(&:to_sym).freeze
    REGULAR_STEPS = Grumlin.definitions.dig(:steps, :regular).map(&:to_sym).freeze
    CONFIGURATION_STEPS = Grumlin.definitions.dig(:steps, :configuration).map(&:to_sym).freeze

    ALL_STEPS = START_STEPS + CONFIGURATION_STEPS + REGULAR_STEPS

    def initialize(client: nil)
      @client = client
      return if respond_to?(:shortcuts)

      raise "steppable must not be initialized directly, use Grumlin::Shortcuts::Storage#g or #__ instead"
    end

    ALL_STEPS.each do |step|
      define_method step do |*args, **params|
        shortcuts.action_class.new(step, args: args, params: params, previous_step: self)
      end
    end

    def step(name, *args, **params)
      shortcuts.action_class.new(name, args: args, params: params, previous_step: self)
    end

    def_delegator :shortcuts, :__
  end
end
