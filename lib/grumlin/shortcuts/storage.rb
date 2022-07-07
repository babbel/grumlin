# frozen_string_literal: true

module Grumlin
  module Shortcuts
    class Storage
      def self.[](other)
        new(other)
      end

      def initialize(storage = {})
        @storage = storage
      end

      def [](key)
        @storage[key]
      end

      def known?(key)
        @storage.include?(key)
      end

      def ==(other)
        @storage == other.storage
      end

      def names
        @storage.keys
      end

      def add(name, shortcut = nil)
        raise ArgumentError, "shortcut '#{name}' already exists" if known?(name) && @storage[name] != shortcut

        @storage[name] = shortcut
      end

      def add_from(other)
        other.storage.each do |name, shortcut|
          add(name, shortcut)
        end
      end

      def g
        __
      end

      def __
        @__ ||= TraversalStart.new(self)
      end

      protected

      attr_reader :storage
    end
  end
end
