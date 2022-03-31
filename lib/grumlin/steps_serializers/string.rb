# frozen_string_literal: true

module Grumlin
  module StepsSerializers
    class String < Serializer
      # constructor params: apply_shortcuts: true|false, default: false
      # constructor params: anonymous: true|false, default: false
      # TODO: add pretty

      def serialize
        steps = @params[:apply_shortcuts] ? ShortcutsApplyer.call(@steps) : @steps

        steps = [steps.configuration_steps, steps.steps].map do |stps|
          stps.map { |step| serialize_step(step) }
        end

        "#{prefix}.#{(steps[0] + steps[1]).join(".")}"
      end

      private

      def serialize_step(step)
        "#{step.name}(#{(step.args + [step.params.any? ? step.params : nil].compact).map do |a|
          serialize_arg(a)
        end.join(", ")})"
      end

      def prefix
        @prefix ||= @params[:anonymous] ? "__" : "g"
      end

      def serialize_arg(arg)
        return "\"#{arg}\"" if arg.is_a?(::String) || arg.is_a?(Symbol)
        return "#{arg.type}.#{arg.value}" if arg.is_a?(Grumlin::TypedValue)
        return arg.to_s if arg.is_a?(Grumlin::Expressions::WithOptions)

        return arg unless arg.is_a?(Steps)

        StepsSerializers::String.new(arg, anonymous: true, **@params).serialize
      end
    end
  end
end
