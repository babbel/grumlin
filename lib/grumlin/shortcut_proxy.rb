# frozen_string_literal: true

module Grumlin
  class ShortcutProxy
    extend Forwardable

    attr_reader :object, :shortcuts

    # shortcuts: {"name": ->(arg) {}}
    def initialize(object, shortcuts, parent: nil)
      @object = object
      @shortcuts = shortcuts
      @parent = parent
    end

    def method_missing(name, *args, **params)
      return @parent.public_send(name, *args, **params) if %i[__ g].include?(name) && !@parent.nil?

      return wrap_result(@object.public_send(name, *args, **params)) if @object.respond_to?(name)

      return wrap_result(@shortcuts[name].apply(self, *args, **params)) if @shortcuts.key?(name)

      super
    end

    # For some reason the interpreter thinks it's private
    public def respond_to_missing?(name, include_private = false) # rubocop:disable Style/AccessModifierDeclarations
      name = name.to_sym

      (%i[__ g].include?(name) &&
      @parent.respond_to?(name)) ||
      @object.respond_to?(name) ||
      @shortcuts.key?(name) ||
      super
    end

    def_delegator :@object, :to_s

    def inspect
      @object.inspect
    end

    private

    def wrap_result(result)
      if result.is_a?(Step) || result.is_a?(Traversal) || result.is_a?(Action)
        return self.class.new(result, @shortcuts, parent: @parent)
      end

      result
    end
  end
end
