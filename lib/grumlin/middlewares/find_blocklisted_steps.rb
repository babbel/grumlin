# frozen_string_literal: true

module Grumlin
  module Middlewares
    class FindBlocklistedSteps < Middleware
      def initialize(app, *steps)
        super(app)
        @validator = QueryValidators::BlocklistedStepsValidator.new(*steps)
      end

      def call(env)
        @validator.validate!(env[:steps_without_shortcuts])
        @app.call(env)
        env[:parsed_results] = @app.call(env).flat_map { |item| Typing.cast(item) }
      end
    end
  end
end
