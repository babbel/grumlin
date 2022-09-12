# frozen_string_literal: true

class Grumlin::Middlewares::CastResults < Grumlin::Middlewares::Middleware
  def call(env)
    env[:parsed_results] = @app.call(env).flat_map { |item| Grumlin::Typing.cast(item) }
  end
end
