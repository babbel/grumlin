# frozen_string_literal: true

module Grumlin
  module Sugar
    def self.included(base)
      base.include(Grumlin::Expressions)
    end

    def __(shortcuts = {})
      Grumlin::TraversalStart.new(shortcuts) # TODO: allow only regular and start steps
    end

    def g(shortcuts = {})
      Grumlin::TraversalStart.new(shortcuts)
    end
  end
end
