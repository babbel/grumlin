# frozen_string_literal: true

module Grumlin
  class Action
    extend Forwardable

    attr_reader :step

    def initialize(step)
      @step = step
    end

    def_delegator :@step, :to_s
    def_delegator :@step, :inspect

    def method_missing(name, *args, **params)
      @step.public_send(name, *args, **params).tap do |result|
        if result.is_a?(AnonymousStep) || result.is_a?(Traversal) || result.is_a?(ShortcutProxy)
          return self.class.new(result)
        end
      end
    end

    def respond_to_missing?(name, include_private = false)
      @step.respond_to?(name, include_private)
    end
  end
end
