# frozen_string_literal: true

module Grumlin
  class ShortcutProxy
    # shortcuts: {"name": ->() {}}
    extend Forwardable

    def initialize(object, shortcuts)
      @object = object
      @shortcuts = shortcuts
    end

    def method_missing(name, *args)
      return wrap_result(@object.send(name, *args)) if @object.respond_to?(name)

      return wrap_result(@object.instance_exec(*args, &@shortcuts[name])) if @shortcuts.key?(name)

      super
    end

    def_delegator :@object, :to_s

    def inspect
      @object.inspect
    end

    def respond_to_missing?(name)
      @object.respond_to?(name) || @shortcuts.key?(name)
    end

    private

    def wrap_result(result)
      return self.class.new(result, @shortcuts) if result.is_a?(AnonymousStep)

      result
    end
  end
end
