# frozen_string_literal: true

module Grumlin
  module Middlewares
    class FindMutatingSteps < FindBlocklistedSteps
      MUTATING_STEPS = %i[addV addE property drop].freeze

      def initialize(app)
        super(app, *MUTATING_STEPS)
      end
    end
  end
end
