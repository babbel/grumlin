# frozen_string_literal: true

module Grumlin
  class AnonymousStep
    attr_reader :name, :args

    def initialize(name, *args, previous_steps: [])
      @name = name
      @previous_steps = previous_steps
      @args = args
    end

    %w[addV addE V E limit count drop property valueMap select from to as order by].each do |step|
      define_method step do |*args|
        add_step(step, args, previous_steps: steps)
      end
    end

    alias addVertex addV
    alias addEdge addE

    # TODO: memoization
    def inspect
      @inspect ||= Translator.to_bytecode(steps).to_s
    end

    alias to_s inspect

    def steps
      (@previous_steps + [self])
    end

    private

    def add_step(step_name, args, previous_steps:)
      self.class.new(step_name, *args, previous_steps: previous_steps)
    end
  end
end
