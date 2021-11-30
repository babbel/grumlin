# frozen_string_literal: true

module Grumlin
  module Repository
    def self.extended(base)
      base.extend(Grumlin::Shortcuts)
      base.include(Grumlin::Tools)
      base.shortcut :props do |**props|
        props.reduce(self) do |tt, (prop, value)|
          tt.property(prop, value)
        end
      end

      base.shortcut :hasAll do |**props|
        props.reduce(self) do |tt, (prop, value)|
          tt.has(prop, value)
        end
      end
    end
  end
end
