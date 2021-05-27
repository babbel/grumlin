# frozen_string_literal: true

module Grumlin
  module Translator
    class << self
      def to_string_query(steps) # rubocop:disable Metrics/MethodLength
        counter = 0
        string_steps, bindings = steps.each_with_object([[], {}]) do |step, (acc_g, acc_b)|
          args = step.args.map do |arg|
            binding_name(counter).tap do |b|
              acc_b[b] = arg
              counter += 1
            end
          end.join(", ")

          acc_g << "#{step.name}(#{args})"
        end

        ["g.#{string_steps.join(".")}", bindings]
      end

      def to_bytecode_query(steps)
        steps.map do |step|
          [step.name, *step.args.flatten]
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
    end
  end
end
