# frozen_string_literal: true

module Grumlin::Expressions::Scope
  SUPPORTED_STEPS = Grumlin.definitions.dig(:expressions, :scope).map(&:to_sym).freeze

  class << self
    extend Grumlin::Expressions::Expression

    define_steps(SUPPORTED_STEPS, "Scope")
  end
end
