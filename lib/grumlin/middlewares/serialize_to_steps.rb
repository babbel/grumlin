# frozen_string_literal: true

class Grumlin::Middlewares::SerializeToSteps < Grumlin::Middlewares::Middleware
  def call(env)
    env[:steps] = Grumlin::Steps.from(env[:traversal])
    @app.call(env)
  end
end
