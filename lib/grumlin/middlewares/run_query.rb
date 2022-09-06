# frozen_string_literal: true

module Grumlin
  module Middlewares
    class RunQuery
      def initialize(app)
        @app = app
      end

      def call(env)
        env[:executor].call
      end
    end
  end
end
