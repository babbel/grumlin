# frozen_string_literal: true

module Grumlin
  class Action
    extend Forwardable

    attr_reader :action_step

    def initialize(step)
      @action_step = step
    end

    def_delegator :@action_step, :to_s
    def_delegator :@action_step, :inspect

    def method_missing(name, *args, **params)
      @action_step.public_send(name, *args, **params).tap do |result|
        return self.class.new(result) if result.is_a?(Step) || result.is_a?(Traversal) || result.is_a?(ShortcutProxy)
      end
    end

    def respond_to_missing?(name, include_private = false)
      @action_step.respond_to?(name, include_private)
    end
  end
end
