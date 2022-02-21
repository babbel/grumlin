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

      # FIXME
      def to_bytecode
        { :@type => "g:Bytecode", :@value => serialize }
      end

      private

      def serialize_step(step)
        [step.name, *step.arguments.map { |arg| serialize_arg(arg) }]
      end

      def serialize_arg(arg)
        return arg.to_bytecode if arg.respond_to?(:to_bytecode) # TODO: serialize everything here

        return arg unless arg.is_a?(Steps)

        Bytecode.new(arg, **@params.merge(no_return: false)).to_bytecode
      end
    end
  end
end
