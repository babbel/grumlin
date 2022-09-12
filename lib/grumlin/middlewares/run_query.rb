# frozen_string_literal: true

class Grumlin::Middlewares::RunQuery < Grumlin::Middlewares::Middleware
  def call(env)
    env[:results] = env[:pool].acquire { |c| c.write(env[:query]) }
  end
end
