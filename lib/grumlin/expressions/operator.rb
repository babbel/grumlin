# frozen_string_literal: true

module Grumlin
  module Expressions
    module Operator
      extend Expression

      SUPPORTED_STEPS = %i[addAll and assign div max min minus mult or sum].freeze

      define_steps(SUPPORTED_STEPS, "Operator")
    end
  end
end
