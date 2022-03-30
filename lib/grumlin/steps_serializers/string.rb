# frozen_string_literal: true

module Grumlin
  module StepsSerializers
    class String < Serializer
      # constructor params: apply_shortcuts: true|false, default: false
      # constructor params: anonymous: true|false, default: false
      # TODO: add pretty

      def serialize
        steps = @params[:apply_shortcuts] ? ShortcutsApplyer.call(@steps) : @steps

        configuration_steps = serialize_steps(steps.configuration_steps)
        regular_steps = serialize_steps(steps.steps)

        "#{prefix}.#{(configuration_steps + regular_steps).join(".")}"
      end

      private

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

      def serialize_steps(steps)
        steps.map do |step|
          "#{step.name}(#{(step.args + [step.params.any? ? step.params : nil].compact).map do |a|
                            serialize_arg(a)
                          end.join(", ")})"
        end
      end
    end
  end
end
