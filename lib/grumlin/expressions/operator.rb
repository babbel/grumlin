# frozen_string_literal: true

module Grumlin
  module Expressions
    module Operator
      SUPPORTED_STEPS = %i[addAll and assign div max min minus mult or sum].freeze

      class << self
        extend Expression

        define_steps(SUPPORTED_STEPS, "Operator")
      end
    end
  end
end
