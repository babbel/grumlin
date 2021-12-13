# frozen_string_literal: true

module Grumlin
  module Expressions
    module Pop
      extend Expression

      SUPPORTED_STEPS = %i[all first last mixed].freeze

      define_steps(SUPPORTED_STEPS, "Pop")
    end
  end
end
