# frozen_string_literal: true

module Grumlin
  module Sugar
    def self.included(base)
      base.include(Grumlin::Expressions)
    end

    def __
      Grumlin::Expressions::U
    end

    def g
      Grumlin::TraversalStart.new({})
    end
  end
end
