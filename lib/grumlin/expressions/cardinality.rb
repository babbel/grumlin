# frozen_string_literal: true

module Grumlin::Expressions::Cardinality
  SUPPORTED_STEPS = Grumlin.definitions.dig(:expressions, :cardinality).map(&:to_sym).freeze

  class << self
    extend Grumlin::Expressions::Expression

    define_steps(SUPPORTED_STEPS, "Cardinality")
  end
end
