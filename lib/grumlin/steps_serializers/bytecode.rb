# frozen_string_literal: true

module Grumlin
  module StepsSerializers
    class Bytecode < Serializer
      # constructor params: no_return: true|false, default false
      # TODO: add pretty

      NONE_STEP = StepData.new("none", [])

      def serialize
        steps = ShortcutsApplyer.call(@steps)
        no_return = @params[:no_return] || false

        {
          step: (steps.steps + (no_return ? [NONE_STEP] : [])).map { |s| serialize_step(s) }
        }.tap do |v|
          v.merge!(source: steps.configuration_steps.map { |s| serialize_step(s) }) if steps.configuration_steps.any?
        end
      end

      private

      def serialize_step(step)
        [step.name, *step.arguments.map { |arg| serialize_arg(arg) }]
      end

      def serialize_arg(arg)
        return serialize_typed_value(arg) if arg.is_a?(TypedValue)
        return serialize_predicate(arg) if arg.is_a?(Expressions::P::Predicate)
        return arg.value if arg.is_a?(Expressions::WithOptions)

        return arg unless arg.is_a?(Steps)

        { :@type => "g:Bytecode", :@value => Bytecode.new(arg, **@params.merge(no_return: false)).serialize }
      end

      def serialize_typed_value(value)
        return value.value if value.type.nil?

        {
          "@type": "g:#{value.type}",
          "@value": value.value
        }
      end

      def serialize_predicate(value)
        {
          "@type": "g:P",
          "@value": {
            predicate: value.name,
            value: if value.type.nil?
                     value.value
                   else
                     {
                       "@type": "g:#{value.type}",
                       "@value": value.value
                     }
                   end
          }
        }
      end
    end
  end
end
