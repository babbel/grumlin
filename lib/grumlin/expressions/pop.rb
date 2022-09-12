# frozen_string_literal: true

module Grumlin::Expressions::Pop
  SUPPORTED_STEPS = Grumlin.definitions.dig(:expressions, :pop).map(&:to_sym).freeze

  class << self
    extend Grumlin::Expressions::Expression

    define_steps(SUPPORTED_STEPS, "Pop")
  end
end
