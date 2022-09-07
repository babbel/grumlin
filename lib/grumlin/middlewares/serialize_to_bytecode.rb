# frozen_string_literal: true

module Grumlin
  module Middlewares
    class SerializeToBytecode < Middleware
      def call(env)
        env[:bytecode] = StepsSerializers::Bytecode.new(env[:steps_without_shortcuts],
                                                        no_return: !env[:need_results]).serialize
        @app.call(env)
      end
    end
  end
end
