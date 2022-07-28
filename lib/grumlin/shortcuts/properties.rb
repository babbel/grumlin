# frozen_string_literal: true

module Grumlin
  module Shortcuts
    module Properties
      extend Grumlin::Shortcuts

      shortcut :props do |cardinality = nil, **props|
        props.reduce(self) do |tt, (prop, value)|
          next tt if value.nil? # nils are not supported
          next tt.property(prop, value) if cardinality.nil?

          tt.property(cardinality, prop, value)
        end
      end

      shortcut :hasAll do |**props|
        props.reduce(self) do |tt, (prop, value)|
          tt.has(prop, value)
        end
      end
    end
  end
end
