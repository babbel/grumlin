# frozen_string_literal: true

module Grumlin
  module Expressions
    module Order
      SUPPORTED_STEPS = %i[asc desc shuffle].freeze

      class << self
        extend Expression

        define_steps(SUPPORTED_STEPS, "Order")
      end
    end
  end
end
