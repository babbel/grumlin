# frozen_string_literal: true

module Grumlin
  class Shortcut
    extend Forwardable

    attr_reader :name, :block

    def_delegator :@block, :arity
    def_delegator :@block, :source_location

    def initialize(name, &block)
      @name = name
      @block = block
    end

    def ==(other)
      @name == other.name && @block == other.block
    end

    # TODO: to_s, inspect, preview

    def apply(object, *args, **params)
      object.instance_exec(*args, **params, &@block)
    end
  end
end
