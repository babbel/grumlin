# frozen_string_literal: true

module Grumlin
  module Middlewares
    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        raise NotImplementedError
      end
    end
  end
end
