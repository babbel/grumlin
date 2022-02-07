# frozen_string_literal: true

module Grumlin
  module Shortcuts
    module InstanceMethods
      def with_shortcuts(obj)
        Action.new(obj, shortcuts: self.class.shortcuts, context: self)
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

    def shortcut(name, shortcut = nil, &block) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      name = name.to_sym
      # TODO: blocklist of names to avoid conflicts with standard methods?
      if Grumlin::Step::SUPPORTED_STEPS.include?(name)
        raise ArgumentError,
              "cannot use names of standard gremlin steps"
      end

      if (shortcut.nil? && block.nil?) || (shortcut && block)
        raise ArgumentError, "either shortcut or block must be passed"
      end

      shortcut ||= Shortcut.new(name, &block)

      raise ArgumentError, "shortcut '#{name}' already exists" if shortcuts.key?(name) && shortcuts[name] != shortcut

      shortcuts[name] = shortcut
    end

    def shortcuts_from(other_shortcuts)
      other_shortcuts.shortcuts.each do |name, shortcut|
        shortcut(name, shortcut)
      end
    end

    def shortcuts
      @shortcuts ||= {}
    end
  end
end
