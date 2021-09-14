# frozen_string_literal: true

module Grumlin
  # Incapsulates logic of converting step chains and step arguments to queries that can be sent to the server
  # and to human readable strings.
  class Bytecode
    class NoneStep
      def to_bytecode
        ["none"]
      end
    end

    NONE_STEP = NoneStep.new

    def initialize(step, no_return: false)
      @step = step
      @no_return = no_return
    end

    def inspect
      to_readable_bytecode.to_s
    end
    alias to_s inspect

    def to_query
      {
        requestId: SecureRandom.uuid,
        op: "bytecode",
        processor: "traversal",
        args: {
          gremlin: to_bytecode,
          aliases: { g: :g }
        }
      }
    end

    def to_readable_bytecode
      @to_readable_bytecode ||= steps.map { |s| serialize_arg(s, serialization_method: :to_readable_bytecode) }
    end

    def to_bytecode
      @to_bytecode ||= TypedValue.new("Bytecode", { step: (steps + (@no_return ? [NONE_STEP] : [])).map do |s|
                                                            serialize_arg(s)
                                                          end }).to_bytecode
    end

    private

    # Serializes step or a step argument to either an executable query or a human readable string representation
    # depending on the `serialization_method` parameter. I should be either `:to_readable_bytecode` for human readable
    # representation or `:to_bytecode` for query.
    def serialize_arg(arg, serialization_method: :to_bytecode)
      return arg.send(serialization_method) if arg.respond_to?(:to_bytecode)
      return arg unless arg.is_a?(AnonymousStep)

      arg.args.flatten.each.with_object([arg.name]) do |a, res|
        res << if a.instance_of?(AnonymousStep)
                 a.bytecode.send(serialization_method)
               else
                 serialize_arg(a, serialization_method: serialization_method)
               end
      end
    end

    def steps
      @steps ||= [].tap do |result|
        step = @step
        until step.nil?
          result.unshift(step)
          step = step.previous_step
        end
      end
    end
  end
end
