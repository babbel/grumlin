# frozen_string_literal: true

module Grumlin
  module Shortcuts
    def self.extended(base)
      base.include(Grumlin::Expressions)
    end

    def inherited(subclass)
      super
      subclass.shortcuts_from(self)
    end

    def shortcut(name, shortcut = nil, override: false, lazy: true, &block) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      name = name.to_sym
      lazy = false if override

      if Grumlin::Action::REGULAR_STEPS.include?(name) && !override
        raise ArgumentError,
              "overriding standard gremlin steps is not allowed, if you know what you're doing, pass `override: true`"
      end

      if (shortcut.nil? && block.nil?) || (shortcut && block)
        raise ArgumentError, "either shortcut or block must be passed"
      end

      shortcuts.add(name, shortcut || Shortcut.new(name, lazy: lazy, &block))
    end

    def shortcuts_from(other_shortcuts)
      shortcuts.add_from(other_shortcuts.shortcuts)
    end

    def shortcuts
      @shortcuts ||= Storage.new
    end
  end
end
