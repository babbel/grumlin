# frozen_string_literal: true

module Grumlin
  module Expressions
    module Order
      SUPPORTED_STEPS = Grumlin.definitions.dig(:expressions, :order).map(&:to_sym).freeze

      class << self
        extend Expression

        define_steps(SUPPORTED_STEPS, "Order")
      end
    end
  end
end
