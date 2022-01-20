# frozen_string_literal: true

module Grumlin
  module Shortcuts
    module InstanceMethods
      def with_shortcuts(obj)
        ShortcutProxy.new(obj, self.class.shortcuts, parent: self)
      end
    end

    def self.extended(base)
      base.include(InstanceMethods)
      base.include(Grumlin::Expressions)
    end

    def inherited(subclass)
      super
      subclass.shortcuts_from(self)
    end

    def shortcut(name, &block)
      name = name.to_sym
      # TODO: blocklist of names to avoid conflicts with standard methods?
      if Grumlin::AnonymousStep::SUPPORTED_STEPS.include?(name)
        raise ArgumentError,
              "cannot use names of standard gremlin steps"
      end

      raise ArgumentError, "shortcut '#{name}' already exists" if shortcuts.key?(name) && shortcuts[name] != block

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
  end
end
