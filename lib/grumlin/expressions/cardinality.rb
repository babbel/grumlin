# frozen_string_literal: true

module Grumlin
  module Expressions
    module Cardinality
      SUPPORTED_STEPS = Grumlin.definitions.dig(:expressions, :cardinality).map(&:to_sym).freeze

      class << self
        extend Expression

        define_steps(SUPPORTED_STEPS, "Cardinality")
      end
    end
  end
end
