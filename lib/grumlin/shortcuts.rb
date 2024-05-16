# frozen_string_literal: true

module Grumlin::Shortcuts
  def self.extended(base)
    base.include(Grumlin::Expressions)
  end

  def inherited(subclass)
    super
    subclass.shortcuts_from(self)
  end

  def shortcut(name, shortcut = nil, override: false, lazy: true, &block)
    name = name.to_sym
    lazy = false if override

    if Grumlin::Step::REGULAR_STEPS.include?(name) && !override
      raise ArgumentError,
            "overriding standard gremlin steps is not allowed, if you know what you're doing, pass `override: true`"
    end

    raise ArgumentError, "either shortcut or block must be passed" if [shortcut, block].count(&:nil?) != 1

    shortcuts.add(name, shortcut || Grumlin::Shortcut.new(name, lazy:, &block))
  end

  def shortcuts_from(other_shortcuts)
    shortcuts.add_from(other_shortcuts.shortcuts)
  end

  def shortcuts
    @shortcuts ||= Storage.new
  end
end
