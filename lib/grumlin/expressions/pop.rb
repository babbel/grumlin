# frozen_string_literal: true

module Grumlin
  module Expressions
    module Pop
      SUPPORTED_STEPS = Grumlin.definitions.dig(:expressions, :pop).map(&:to_sym).freeze

      class << self
        extend Expression

        define_steps(SUPPORTED_STEPS, "Pop")
      end
    end
  end
end
