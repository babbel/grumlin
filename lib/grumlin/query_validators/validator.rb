# frozen_string_literal: true

class Grumlin
  module QueryAnalyzers
    class Validator
      class ValidationError < Grumlin::Error
        attr_reader :errors, :steps

        def initialize(steps, errors)
          super("#{steps} is invalid: #{errors}")
          @steps = steps
          @errors = errors
        end
      end

      # steps is an instance of `Steps` after shortcuts applied
      def validate!(steps)
        return unless (err = errors(steps)).any?

        raise ValidationError, err
      end

      def valid?(steps)
        errors(steps).any?
      end

      protected

      def errors(steps)
        {}.tap do |errors|
          validate(steps, errors)
        end
      end

      def validate(steps, errors)
        raise NotImplementedError
      end
    end
  end
end
