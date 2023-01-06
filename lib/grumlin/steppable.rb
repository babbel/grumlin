# frozen_string_literal: true

class Grumlin::Steppable
  extend Forwardable

  attr_reader :session_id, :pool

  START_STEPS = Grumlin.definitions.dig(:steps, :start).map(&:to_sym).freeze
  REGULAR_STEPS = Grumlin.definitions.dig(:steps, :regular).map(&:to_sym).freeze
  CONFIGURATION_STEPS = Grumlin.definitions.dig(:steps, :configuration).map(&:to_sym).freeze

  ALL_STEPS = START_STEPS + CONFIGURATION_STEPS + REGULAR_STEPS

  def initialize(pool: nil, session_id: nil, middlewares: Grumlin.default_middlewares)
    @pool = pool
    @session_id = session_id
    @middlewares = middlewares

    return if respond_to?(:shortcuts)

    raise "steppable must not be initialized directly, use Grumlin::Shortcuts::Storage#g or #__ instead"
  end

  ALL_STEPS.each do |step|
    define_method step do |*args, **params|
      shortcuts.step_class.new(step, args: args, params: params, previous_step: self,
                                     session_id: @session_id, pool: @pool, middlewares: @middlewares)
    end
  end

  def step(name, *args, **params)
    shortcuts.step_class.new(name, args: args, params: params, previous_step: self,
                                   session_id: @session_id, pool: @pool, middlewares: @middlewares)
  end

  def_delegator :shortcuts, :__
end
