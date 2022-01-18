# frozen_string_literal: true

module Grumlin
  class AnonymousStep
    attr_reader :name, :previous_step, :configuration_steps

    # TODO: add other steps
    SUPPORTED_STEPS = %i[E V addE addV aggregate and as both bothE by choose coalesce count dedup drop elementMap emit
                         fold from group groupCount has hasId hasLabel hasNot id identity in inE inV is label limit
                         map not or order out outE path project properties property range repeat sack select sideEffect
                         skip sum tail to unfold union until valueMap values where with].freeze

    def initialize(name, *args, configuration_steps: [], previous_step: nil, **params)
      @name = name
      @previous_step = previous_step
      @args = args
      @params = params
      @configuration_steps = configuration_steps
    end

    SUPPORTED_STEPS.each do |step|
      define_method(step) do |*args, **params|
        step(step, *args, **params)
      end
    end

    def step(name, *args, **params)
      self.class.new(name, *args, previous_step: self, configuration_steps: configuration_steps, **params)
    end

    def inspect
      bytecode.inspect
    end

    def to_s
      inspect
    end

    def bytecode(no_return: false)
      @bytecode ||= Bytecode.new(self, no_return: no_return)
    end

    def args
      [*@args].tap do |args|
        args << @params if @params.any?
      end
    end
  end
end
