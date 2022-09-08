# frozen_string_literal: true

module Grumlin
  module Middlewares
    class FrozenBuilder < ::Middleware::Builder
      def initialize(opts = nil, &block)
        super(opts, &block)
        freeze
      end

      def freeze
        super

        stack.freeze
      end
    end
  end
end
