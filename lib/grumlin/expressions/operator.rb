# frozen_string_literal: true

module Grumlin::Expressions::Operator
  SUPPORTED_STEPS = Grumlin.definitions.dig(:expressions, :operator).map(&:to_sym).freeze

  class << self
    extend Grumlin::Expressions::Expression

    define_steps(SUPPORTED_STEPS, "Operator")
  end
end
