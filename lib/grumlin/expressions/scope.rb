# frozen_string_literal: true

module Grumlin
  module Expressions
    module Scope
      SUPPORTED_STEPS = Grumlin.definitions.dig(:expressions, :scope).map(&:to_sym).freeze

      class << self
        extend Expression

        define_steps(SUPPORTED_STEPS, "Scope")
      end
    end
  end
end
