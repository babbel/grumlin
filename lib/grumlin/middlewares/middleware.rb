# frozen_string_literal: true

class Grumlin::Middlewares::Middleware
  def initialize(app)
    @app = app
  end

  def call(env)
    raise NotImplementedError
  end
end
