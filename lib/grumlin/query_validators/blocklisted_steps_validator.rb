# frozen_string_literal: true

class Grumlin
  module QueryValidators
    class BlocklistedStepsValidator < Validator
      def initialize(*names)
        super()
        @names = names.to_set
      end

      protected

      def validate(_steps, _errors = {})
        false
      end
    end
  end
end
