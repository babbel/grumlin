# frozen_string_literal: true

module Grumlin
  class Step
    attr_reader :client, :name, :args

    # TODO: add support for bytecode
    def initialize(client, name, *args, previous_steps: [])
      @client = client
      @name = name
      @previous_steps = previous_steps
      @args = args
    end

    %w[addV addE V E limit count drop property valueMap select from to as].each do |step|
      define_method step do |*args|
        Step.new(@client, step, *args, previous_steps: steps)
      end
    end

    alias addVertex addV
    alias addEdge addE

    # TODO: add support for next
    # TODO: add support for iterate
    # TODO: memoization
    def toList # rubocop:disable Naming/MethodName
      @client.query(*steps)
    end

    def inspect
      "<Step #{self}>" # TODO: substitute bindings
    end

    # TODO: memoization
    def to_s(*)
      Translator.to_string(steps)
    end

    alias to_gremlin to_s

    def steps
      (@previous_steps + [self])
    end
  end
end
