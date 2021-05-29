# frozen_string_literal: true

module Grumlin
  module Translator
    class << self
      def to_bytecode(steps)
        return arg_to_bytecode(steps) if steps.is_a?(AnonymousStep)

        steps.map do |step|
          arg_to_bytecode(step)
        end
      end

      def to_bytecode_query(steps)
        steps.map do |step|
          arg_to_query_bytecode(step)
        end
      end

      def to_string(steps)
        "g." + steps.map do |step| # rubocop:disable Style/StringConcatenation
          "#{step.name}(#{step.args.map(&:inspect).join(", ")})"
        end.join(".")
      end

      private

      def binding_name(num)
        "b_#{num.to_s(16)}"
      end

      def arg_to_bytecode(arg)
        return arg unless arg.is_a?(AnonymousStep)

        args = arg.args.flatten.map do |a|
          bc = arg_to_bytecode(a)
          a.instance_of?(AnonymousStep) ? [bc] : bc
        end
        [arg.name, *args]
      end

      def arg_to_query_bytecode(arg)
        return arg unless arg.is_a?(AnonymousStep)

        args = arg.args.flatten.map do |a|
          bc = arg_to_query_bytecode(a)
          a.instance_of?(AnonymousStep) ? Typing.to_bytecode([bc]) : bc
        end
        [arg.name, *args]
      end
    end
  end
end
