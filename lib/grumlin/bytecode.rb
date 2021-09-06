# frozen_string_literal: true

module Grumlin
  class Bytecode
    def initialize(step)
      @step = step
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

    def to_bytecode
      @to_bytecode ||= steps.map { |s| Translator.to_bytecode(s) }
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
          gremlin: Typing.as_bytecode(Translator.to_bytecode_query(steps)),
          aliases: { g: :g }
        }
      }
    end
  end
end
