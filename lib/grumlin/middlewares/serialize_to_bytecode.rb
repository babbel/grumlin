# frozen_string_literal: true

class Grumlin::Middlewares::SerializeToBytecode < Grumlin::Middlewares::Middleware
  def call(env)
    env[:bytecode] = Grumlin::StepsSerializers::Bytecode.new(env[:steps_without_shortcuts],
                                                             no_return: !env[:need_results]).serialize
    @app.call(env)
  end
end
