# frozen_string_literal: true

module Grumlin
  module Repository
    module InstanceMethods
      def __
        with_shortcuts(Grumlin::Tools::U)
      end

      def g
        with_shortcuts(Grumlin::Traversal.new)
      end

      private

      def with_shortcuts(obj)
        ShortcutProxy.new(obj, self.class.shortcuts)
      end
    end

    def self.extended(base)
      base.include Grumlin::Tools
      base.include InstanceMethods
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

    def shortcut(name, &block)
      shortcuts[name] = block
    end

    def shortcuts
      @shortcuts ||= {}
    end
  end
end
