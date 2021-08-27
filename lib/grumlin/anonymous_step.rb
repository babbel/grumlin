# frozen_string_literal: true

module Grumlin
  class AnonymousStep
    attr_reader :name, :args

    SUPPORTED_STEPS = %w[E V addE addV as by coalesce count dedup drop elementMap emit fold from group groupCount has
                         hasLabel hasNot in inV label limit not order out outE path project property repeat select to
                         unfold valueMap values where].freeze

    def initialize(name, *args, previous_steps: [])
      @name = name
      @previous_steps = previous_steps
      @args = args
    end

    SUPPORTED_STEPS.each do |step|
      define_method step do |*args|
        add_step(step, args, previous_steps: steps)
      end
    end

    def inspect
      @inspect ||= to_bytecode.to_s
    end

    alias to_s inspect

    def to_bytecode
      @to_bytecode ||= (@previous_steps.last&.to_bytecode || []) + [Translator.to_bytecode(self)]
    end

    def steps
      (@previous_steps + [self])
    end

    private

    def add_step(step_name, args, previous_steps:)
      self.class.new(step_name, *args, previous_steps: previous_steps)
    end
  end
end
