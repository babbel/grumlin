# frozen_string_literal: true

module Grumlin
  module Expressions
    module Operator
      SUPPORTED_STEPS = Grumlin.definitions.dig(:expressions, :operator).map(&:to_sym).freeze

      class << self
        extend Expression

        define_steps(SUPPORTED_STEPS, "Operator")
      end
    end
  end
end
