# frozen_string_literal: true

module Grumlin
  module Middlewares
    class BuildQuery < Middleware
      def call(env)
        env[:query] = {
          requestId: SecureRandom.uuid,
          op: :bytecode,
          processor: env[:session_id] ? :session : :traversal,
          args: {
            gremlin: {
              :@type => "g:Bytecode",
              :@value => env[:bytecode]
            },
            aliases: { g: :g },
            session: env[:session_id]
          }.compact
        }
        @app.call(env)
      end
    end
  end
end
