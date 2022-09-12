# frozen_string_literal: true

class Grumlin::Middlewares::FindBlocklistedSteps < Grumlin::Middlewares::Middleware
  def initialize(app, *steps)
    super(app)
    @validator = Grumlin::QueryValidators::BlocklistedStepsValidator.new(*steps)
  end

  def call(env)
    @validator.validate!(env[:steps_without_shortcuts])
    @app.call(env)
    env[:parsed_results] = @app.call(env).flat_map { |item| Grumlin::Typing.cast(item) }
  end
end
