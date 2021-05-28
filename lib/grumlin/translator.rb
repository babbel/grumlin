# frozen_string_literal: true

module Grumlin
  module Translator
    class << self
      # TODO: support subtraversals
      def to_string_query(steps, counter = 0, bindings = {})
        string_steps = steps.each_with_object([]) do |step, acc_g|
          args = step.args.map do |arg|
            binding_name(counter).tap do |b|
              bindings[b] = arg
              counter += 1
            end
          end.join(", ")

          acc_g << "#{step.name}(#{args})"
        end

        ["g.#{string_steps.join(".")}", bindings]
      end

      def to_bytecode(steps)
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
