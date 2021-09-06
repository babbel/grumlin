# frozen_string_literal: true

module Grumlin
  class AnonymousStep
    attr_reader :name, :args, :previous_step

    # TODO: add other steps
    SUPPORTED_STEPS = %w[E V addE addV as by coalesce count dedup drop elementMap emit fold from group groupCount has
                         hasId hasLabel hasNot in inV label limit not order out outE path project property repeat select
                         to unfold valueMap values where].freeze

    def initialize(name, *args, previous_step: nil)
      @name = name
      @previous_step = previous_step
      @args = args
    end

    SUPPORTED_STEPS.each do |step|
      define_method(step) do |*args|
        add_step(step, args)
      end
    end

    def inspect
      @inspect ||= to_bytecode.to_s
    end

    alias to_s inspect

    def to_bytecode
      @to_bytecode ||= steps.map { |s| Translator.to_bytecode(s) }
    end

    def steps
      @steps ||= begin
        step = self
        [].tap do |result|
          until step.nil?
            result << step
            step = step.previous_step
          end
        end.reverse
      end
    end

    private

    def add_step(step_name, args)
      self.class.new(step_name, *args, previous_step: self)
    end
  end
end
