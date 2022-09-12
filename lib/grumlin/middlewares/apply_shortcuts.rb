# frozen_string_literal: true

class Grumlin::Middlewares::ApplyShortcuts < Grumlin::Middlewares::Middleware
  def call(env)
    env[:steps_without_shortcuts] = Grumlin::ShortcutsApplyer.call(env[:steps])
    @app.call(env)
  end
end
