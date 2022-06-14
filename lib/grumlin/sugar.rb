# frozen_string_literal: true

module Grumlin
  module Sugar
    def self.included(base)
      base.include(Grumlin::Expressions)
    end

    def __(shortcuts = Grumlin::Shortcuts::Storage.new)
      Grumlin::TraversalStart.new(shortcuts) # TODO: allow only regular and start steps
    end

    def g(shortcuts = Grumlin::Shortcuts::Storage.new)
      Grumlin::TraversalStart.new(shortcuts)
    end
  end
end
