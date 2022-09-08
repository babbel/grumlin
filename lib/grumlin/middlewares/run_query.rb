# frozen_string_literal: true

module Grumlin
  module Middlewares
    class RunQuery < Middleware
      def call(env)
        env[:results] = env[:pool].acquire { |c| c.write(env[:query]) }
      end
    end
  end
end
