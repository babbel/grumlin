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

    def shortcut(name, shortcut = nil, &block)
      name = name.to_sym
      # TODO: blocklist of names to avoid conflicts with standard methods?
      raise ArgumentError, "cannot use names of standard gremlin steps" if Grumlin::Action::REGULAR_STEPS.include?(name)

      if (shortcut.nil? && block.nil?) || (shortcut && block)
        raise ArgumentError, "either shortcut or block must be passed"
      end

      shortcut ||= Shortcut.new(name, &block)

      shortcuts.add(name, shortcut)
    end

    def shortcuts_from(other_shortcuts)
      shortcuts.add_from(other_shortcuts.shortcuts)
    end

    def shortcuts
      @shortcuts ||= Storage.new
    end
  end
end
