# frozen_string_literal: true

module Grumlin
  module Middlewares
    class SerializeToSteps < Middleware
      def call(env)
        env[:steps] = Steps.from(env[:traversal])
        @app.call(env)
      end
    end
  end
end
