# frozen_string_literal: true

module Grumlin
  module Shortcuts
    module Properties
      extend Grumlin::Shortcuts

      shortcut :props do |**props|
        props.reduce(self) do |tt, (prop, value)| # rubocop:disable Style/EachWithObject
          next tt.property(prop, value) unless value.nil? # nils are not supported

          tt
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
