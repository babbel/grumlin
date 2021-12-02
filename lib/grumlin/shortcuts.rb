# frozen_string_literal: true

module Grumlin
  module Shortcuts
    module InstanceMethods
      def __
        self.class.with_shortcuts(Grumlin::Tools::U)
      end

      def g
        self.class.with_shortcuts(Grumlin::Traversal.new)
      end
    end

    def self.extended(base)
      base.include(InstanceMethods)
    end

    def inherited(subclass)
      super
      subclass.shortcuts_from(self)
    end

    def shortcut(name, &block)
      name = name.to_sym
      if @object.respond_to?(name) || Grumlin::Tools::U::SUPPORTED_STEPS.include?(name)
        raise ArgumentError, "cannot use names of standard gremlin steps"
      end

      raise ArgumentError, "shortcut '#{name}' already exists" if shortcuts.key?(name)

      shortcuts[name] = block
    end

    def shortcuts_from(other_shortcuts)
      other_shortcuts.shortcuts.each do |name, block|
        shortcut(name, &block)
      end
    end

    def shortcuts
      @shortcuts ||= {}
    end

    def with_shortcuts(obj)
      ShortcutProxy.new(obj, shortcuts)
    end
  end
end
