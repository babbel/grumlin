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
        @__ ||= traversal_start_class.new(self)
      end

      def traversal_start_class
        @traversal_start_class ||= shortcut_aware_class(TraversalStart)
      end

      def action_class
        @action_class ||= shortcut_aware_class(Action)
      end

      protected

      attr_reader :storage

      private

      def shortcut_methods
        st = storage
        @shortcut_methods ||= Module.new do
          st.each_key do |k|
            define_method k do |*args, **params|
              step(k, *args, **params)
            end
          end
        end
      end

      def shortcut_aware_class(base)
        methods = shortcut_methods
        Class.new(base) do
          include methods
        end
      end
    end
  end
end
