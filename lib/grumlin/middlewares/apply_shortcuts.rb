# frozen_string_literal: true

module Grumlin
  module Middlewares
    class ApplyShortcuts
      def initialize(app)
        @app = app
      end

      def call(env)
        env[:steps_without_shortcuts] = ShortcutsApplyer.call(env[:steps])
        @app.call(env)
      end
    end
  end
end
