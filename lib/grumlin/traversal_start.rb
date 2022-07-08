# frozen_string_literal: true

module Grumlin
  class TraversalStart < Steppable
    def step(name, *args, **params)
      shortcuts.action_class.new(name, args: args, params: params)
    end

    def to_s(*)
      self.class.to_s
    end

    def inspect
      self.class.inspect
    end
  end
end
