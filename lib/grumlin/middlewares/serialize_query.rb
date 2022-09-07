# frozen_string_literal: true

module Grumlin
  module Middlewares
    class SerializeQuery
      def initialize(app)
        @app = app
      end

      def call(env)
        env[:bytecode] = StepsSerializers::Bytecode.new(env[:traversal].steps, no_return: !env[:need_results])
        @app.call(env)
      end
    end
  end
end
