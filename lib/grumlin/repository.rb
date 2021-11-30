# frozen_string_literal: true

module Grumlin
  module Repository
    def self.extended(base)
      base.extend(Grumlin::Shortcuts)
      base.include(Grumlin::Tools)

      base.shortcuts_from(Grumlin::Shortcuts::Properties)
    end
  end
end
