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

      private

      def arg_to_bytecode(arg)
        return arg.to_bytecode if arg.is_a?(TypedValue)
        return arg unless arg.is_a?(AnonymousStep)

        args = arg.args.flatten.map do |a|
          a.instance_of?(AnonymousStep) ? to_bytecode(a.steps) : arg_to_bytecode(a)
        end
        [arg.name, *args]
      end
    end
  end
end
