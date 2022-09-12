# frozen_string_literal: true

module Grumlin::Expressions::Order
  SUPPORTED_STEPS = Grumlin.definitions.dig(:expressions, :order).map(&:to_sym).freeze

  class << self
    extend Grumlin::Expressions::Expression

    define_steps(SUPPORTED_STEPS, "Order")
  end
end
