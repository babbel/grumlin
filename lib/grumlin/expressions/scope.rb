# frozen_string_literal: true

module Grumlin
  module Expressions
    module Scope
      extend Expression

      SUPPORTED_STEPS = %i[local].freeze

      define_steps(SUPPORTED_STEPS, "Scope")
    end
  end
end
