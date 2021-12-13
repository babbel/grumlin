# frozen_string_literal: true

module Grumlin
  module Expressions
    module Scope
      SUPPORTED_STEPS = %i[local].freeze

      class << self
        extend Expression

        define_steps(SUPPORTED_STEPS, "Scope")
      end
    end
  end
end
