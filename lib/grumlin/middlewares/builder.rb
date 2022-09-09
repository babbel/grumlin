# frozen_string_literal: true

module Grumlin
  module Middlewares
    class Builder < ::Middleware::Builder
      def similar?(other)
        stack == other.stack
      end

      def include?(middleware)
        stack.any? { |m| m.first == middleware }
      end

      def to_app
        @to_app ||= super
      end
    end
  end
end
