# frozen_string_literal: true

module Grumlin
  module Expressions
    module Scope
      extend Tool

      SUPPORTED_STEPS = %i[local].freeze

      define_steps(SUPPORTED_STEPS, "Scope")
    end
  end
end
