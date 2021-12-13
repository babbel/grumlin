# frozen_string_literal: true

module Grumlin
  module Expressions
    module T
      SUPPORTED_STEPS = %i[id label].freeze

      class << self
        extend Expression

        define_steps(SUPPORTED_STEPS, "T")
      end
    end
  end
end
