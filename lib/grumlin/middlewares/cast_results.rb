# frozen_string_literal: true

module Grumlin
  module Middlewares
    class CastResults < Middleware
      def call(env)
        env[:parsed_results] = @app.call(env).flat_map { |item| Typing.cast(item) }
      end
    end
  end
end
