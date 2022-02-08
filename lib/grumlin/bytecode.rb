# frozen_string_literal: true

module Grumlin
  # Incapsulates logic of converting step chains and step arguments to queries that can be sent to the server
  # and to human readable strings.
  class Bytecode < TypedValue
    class NoneStep
      def to_bytecode
        ["none"]
      end
    end

    NONE_STEP = NoneStep.new

    def initialize(action, no_return: false)
      super(type: "Bytecode")

      raise ArgumentError, "expected: #{Action}, got: #{action.class}" unless action.is_a?(Action)

      @action = action
      @no_return = no_return
    end

    def inspect
      configuration_steps = @action.configuration_steps.map do |s|
        serialize_arg(s, serialization_method: :to_readable_bytecode)
      end
      "#{configuration_steps.any? ? configuration_steps : nil}#{to_readable_bytecode}"
    end

    def to_s
      inspect
    end

    def to_readable_bytecode
      @to_readable_bytecode ||= steps.map { |s| serialize_arg(s, serialization_method: :to_readable_bytecode) }
    end

    def value
      @value ||= { step: (steps + (@no_return ? [NONE_STEP] : [])).map { |s| serialize_arg(s) } }.tap do |v|
        v.merge!(source: @action.configuration_steps.map { |s| serialize_arg(s) }) if @action.configuration_steps.any?
      end
    end

    def steps(from_first: true)
      @steps ||= [].tap do |result|
        step = from_first ? @action.first_step : @action
        until step.nil?
          result << step
          step = step.next_step
        end
      end
    end

    private

    # Serializes step or a step argument to either an executable query or a human readable string representation
    # depending on the `serialization_method` parameter. It should be either `:to_readable_bytecode` for human readable
    # representation or `:to_bytecode` for query.
    def serialize_arg(arg, serialization_method: :to_bytecode)
      return arg.public_send(serialization_method) if arg.respond_to?(serialization_method)

      return arg unless arg.is_a?(Step) || arg.is_a?(Action)

      # unless arg.is_a?(Action)
      #   p arg.name
      #   raise "!"
      # end

      arg.args.each.with_object([arg.name.to_s]) do |a, res|
        res << if a.is_a?(Action)
                 Bytecode.new(a).public_send(serialization_method)
               else
                 serialize_arg(a, serialization_method: serialization_method)
               end
      end
    end
  end
end
