# frozen_string_literal: true

module Grumlin
  module Shortcuts
    class Storage
      extend Forwardable

      class << self
        def [](other)
          new(other)
        end

        def empty
          @empty ||= new
        end
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
      def_delegator :self, :__, :g

      def ==(other)
        @storage == other.storage
      end

      def add(name, shortcut)
        @storage[name] = shortcut

        sc = step_class

        shortcut_methods_module.define_method(name) do |*args, **params|
          next sc.new(name, args: args, params: params, previous_step: self, pool: Grumlin.default_pool)
        end
        extend_traversal_classes(shortcut) unless shortcut.lazy?
      end

      def add_from(other)
        other.storage.each do |name, shortcut|
          add(name, shortcut)
        end
      end

      def __
        traversal_start_class.new(pool: Grumlin.default_pool)
      end

      def traversal_start_class
        @traversal_start_class ||= shortcut_aware_class(TraversalStart)
      end

      def step_class
        @step_class ||= shortcut_aware_class(Step)
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

      def extend_traversal_classes(shortcut)
        m = Module.new do
          define_method(shortcut.name, &shortcut.block)
        end
        step_class.include(m)
        traversal_start_class.include(m)
      end
    end
  end
end
