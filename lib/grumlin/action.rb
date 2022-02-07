# frozen_string_literal: true

module Grumlin
  class Action
    extend Forwardable

    attr_reader :action_step, :shortcuts

    def initialize(step, shortcuts: {}, parent: nil)
      @action_step = step
      @shortcuts = shortcuts
      @parent = parent
    end

    def method_missing(name, *args, **params)
      # TODO: why g is here?
      return wrap_result(@parent.public_send(name, *args, **params)) if %i[__ g].include?(name) && !@parent.nil?

      return wrap_result(@action_step.public_send(name, *args, **params)) if @action_step.respond_to?(name)

      return wrap_result(@shortcuts[name].apply(self, *args, **params)) if @shortcuts.key?(name)

      super
    end

    def to_s
      inspect
    end

    def inspect
      bytecode.inspect
    end

    def bytecode(no_return: false)
      @bytecode ||= Bytecode.new(self, no_return: no_return)
    end

    private

    def respond_to_missing?(name, include_private = false)
      name = name.to_sym

      (%i[__ g].include?(name) &&
        @parent.respond_to?(name, include_private)) ||
        @action_step.respond_to?(name, include_private) ||
        @shortcuts.key?(name) ||
        super
    end

    def wrap_result(result)
      return self.class.new(result.action_step, shortcuts: @shortcuts, parent: @parent) if result.is_a?(Action)

      if result.is_a?(Step) || result.is_a?(Traversal)
        return self.class.new(result, shortcuts: @shortcuts, parent: @parent)
      end

      result
    end
  end
end
