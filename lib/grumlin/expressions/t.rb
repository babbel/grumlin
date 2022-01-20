# frozen_string_literal: true

module Grumlin
  module Expressions
    module T
      SUPPORTED_STEPS = Grumlin.definitions.dig(:expressions, :t).map(&:to_sym).freeze

      class << self
        extend Expression

        define_steps(SUPPORTED_STEPS, "T")
      end
    end
  end
end
