# frozen_string_literal: true

module Grumlin
  module Sugar
    def self.included(base)
      base.include(Grumlin::Expressions)
    end

    def __(shortcuts = Grumlin::Shortcuts::Storage.new)
      shortcuts.__
    end

    def g(shortcuts = Grumlin::Shortcuts::Storage.new)
      shortcuts.g
    end
  end
end
