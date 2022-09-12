# frozen_string_literal: true

module Grumlin::Expressions::Column
  SUPPORTED_STEPS = Grumlin.definitions.dig(:expressions, :column).map(&:to_sym).freeze

  class << self
    extend Grumlin::Expressions::Expression

    define_steps(SUPPORTED_STEPS, "Column")
  end
end
