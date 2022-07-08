# frozen_string_literal: true

module Grumlin
  module Shortcuts
    class Storage
      extend Forwardable

      def self.[](other)
        new(other)
      end

      def initialize(storage = {})
        @storage = storage
        storage.each do |n, s|
          add(n, s)
        end
      end

      def_delegator :@storage, :[]
      def_delegator :@storage, :include?, :known?
      def_delegator :@storage, :keys, :names

      def ==(other)
        @storage == other.storage
      end

      def add(name, shortcut)
        raise ArgumentError, "shortcut '#{name}' already exists" if known?(name) && @storage[name] != shortcut

        unless shortcut.lazy?
          m = Module.new do
            define_method(name, &shortcut.block)
          end
          action_class.include(m)
        end

        @storage[name] = shortcut

        shortcut_methods_module.define_method(name) do |*args, **params|
          next step(name, *args, **params)
        end
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
        @__ ||= traversal_start_class.new
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

      def shortcut_methods_module
        @shortcut_methods_module ||= begin
          shorts = self
          Module.new do
            define_method :shortcuts do
              shorts
            end
          end
        end
      end

      def shortcut_aware_class(base)
        methods = shortcut_methods_module
        Class.new(base) do
          include methods
        end
      end
    end
  end
end
