# frozen_string_literal: true

module Grumlin
  class Bytecode
    def initialize(step, no_return: false)
      @step = step
      @no_return = no_return
    end

    def steps
      @steps ||= begin
        step = @step
        [].tap do |result|
          until step.nil?
            result << step
            step = step.previous_step
          end
        end.reverse
      end
    end

    def to_s
      to_bytecode.to_s
    end

    def to_query
      {
        requestId: SecureRandom.uuid,
        op: "bytecode",
        processor: "traversal",
        args: {
          gremlin: as_bytecode(to_bytecode + (@no_return ? [["none"]] : [])),
          aliases: { g: :g }
        }
      }
    end

    protected

    def to_bytecode
      @to_bytecode ||= steps.map { |s| arg_to_query_bytecode(s) }
    end

    private

    def arg_to_query_bytecode(arg)
      return arg.to_bytecode if arg.respond_to?(:to_bytecode)
      return arg unless arg.is_a?(AnonymousStep)

      args = arg.args.flatten.map do |a|
        a.instance_of?(AnonymousStep) ? as_bytecode(a.bytecode.to_bytecode) : arg_to_query_bytecode(a)
      end
      [arg.name, *args]
    end

    def as_bytecode(step)
      {
        "@type": "g:Bytecode",
        "@value": { step: step }
      }
    end
  end
end
