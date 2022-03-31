# frozen_string_literal: true

module Grumlin
  module StepsSerializers
    class HumanReadableBytecode < Bytecode
      def serialize
        steps = ShortcutsApplyer.call(@steps)
        [steps.configuration_steps, steps.steps].map do |stps|
          stps.map { |s| serialize_step(s) }
        end
      end

      private

      def serialize_arg(arg)
        return arg.to_s if arg.is_a?(TypedValue)
        return serialize_predicate(arg) if arg.is_a?(Expressions::P::Predicate)
        return arg.value if arg.is_a?(Expressions::WithOptions)

        return arg unless arg.is_a?(Steps)

        HumanReadableBytecode.new(arg, **@params.merge(no_return: false)).serialize[1]
      end

      def serialize_predicate(arg)
        "#{arg.name}(#{arg.value})"
      end
    end
  end
end
