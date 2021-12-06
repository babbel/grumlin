# frozen_string_literal: true

module Grumlin
  class AnonymousStep
    attr_reader :name, :args, :previous_step, :configuration_steps

    # TODO: add other steps
    SUPPORTED_STEPS = %i[E V addE addV and as both bothE by coalesce count dedup drop elementMap emit fold from group
                         groupCount has hasId hasLabel hasNot id in inE inV is label limit not or order out outE path
                         project property range repeat select sideEffect skip tail to unfold union until valueMap
                         values where with].freeze

    def initialize(name, *args, configuration_steps: [], previous_step: nil)
      @name = name
      @previous_step = previous_step
      @args = args
      @configuration_steps = configuration_steps
    end

    SUPPORTED_STEPS.each do |step|
      define_method(step) do |*args|
        step(step, args)
      end
    end

    def step(name, args)
      self.class.new(name, *args, previous_step: self, configuration_steps: configuration_steps)
    end

    def inspect
      bytecode.inspect
    end

    alias to_s inspect

    def bytecode(no_return: false)
      @bytecode ||= Bytecode.new(self, no_return: no_return)
    end
  end
end
