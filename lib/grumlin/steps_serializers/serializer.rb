# frozen_string_literal: true

module Grumlin
  module StepsSerializers
    class Serializer
      def initialize(steps, **params)
        @steps = steps
        @params = params
      end

      def serialize
        raise NotImplementedError
      end
    end
  end
end
