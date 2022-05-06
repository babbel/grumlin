# frozen_string_literal: true

module Grumlin
  module Expressions
    module Column
      SUPPORTED_STEPS = Grumlin.definitions.dig(:expressions, :column).map(&:to_sym).freeze

      class << self
        extend Expression

        define_steps(SUPPORTED_STEPS, "Column")
      end
    end
  end
end
