# frozen_string_literal: true

module Grumlin
  class ShortcutProxy
    extend Forwardable

    attr_reader :object, :shortcuts

    # shortcuts: {"name": ->(arg) {}}
    def initialize(object, shortcuts)
      @object = object
      @shortcuts = shortcuts
    end

    def method_missing(name, *args)
      return wrap_result(@object.send(name, *args)) if @object.respond_to?(name)

      return wrap_result(instance_exec(*args, &@shortcuts[name])) if @shortcuts.key?(name)

      super
    end

    # For some reason the interpreter thinks it's private
    public def respond_to_missing?(name, include_private = false) # rubocop:disable Style/AccessModifierDeclarations
      name = name.to_sym
      @object.respond_to?(name) || @shortcuts.key?(name) || super
    end

    def_delegator :@object, :to_s

    def inspect
      @object.inspect
    end

    private

    def wrap_result(result)
      return self.class.new(result, @shortcuts) if result.is_a?(AnonymousStep)

      result
    end
  end
end
