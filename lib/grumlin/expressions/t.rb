# frozen_string_literal: true

module Grumlin::Expressions::T
  SUPPORTED_STEPS = Grumlin.definitions.dig(:expressions, :t).map(&:to_sym).freeze

  class << self
    extend Grumlin::Expressions::Expression

    define_steps(SUPPORTED_STEPS, "T")
  end
end
