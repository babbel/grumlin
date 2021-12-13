# frozen_string_literal: true

module Grumlin
  module Expressions
    module Pop
      SUPPORTED_STEPS = %i[all first last mixed].freeze

      class << self
        extend Expression

        define_steps(SUPPORTED_STEPS, "Pop")
      end
    end
  end
end
