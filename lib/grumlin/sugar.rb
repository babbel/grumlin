# frozen_string_literal: true

module Grumlin
  module Sugar
    def self.included(base)
      base.include(Grumlin::Expressions)
    end

    def __
      Action.new(Grumlin::Expressions::U)
    end

    def g
      Action.new(Grumlin::Traversal.new)
    end
  end
end
