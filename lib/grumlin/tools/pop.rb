# frozen_string_literal: true

module Grumlin
  module Tools
    module Pop
      extend Tool

      SUPPORTED_STEPS = %i[all first last mixed].freeze

      define_steps(SUPPORTED_STEPS, "Pop")
    end
  end
end