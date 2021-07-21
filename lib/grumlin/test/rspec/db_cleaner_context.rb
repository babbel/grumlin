# frozen_string_literal: true

module Grumlin
  module Test
    module RSpec
      module DBCleanerContext
      end

      ::RSpec.shared_context DBCleanerContext do
        include DBCleanerContext

        before do
          client = Grumlin::Client.new(Grumlin.config.url)
          Grumlin::Traversal.new(client).V().drop.iterate
          client.disconnect
        end
      end
    end
  end
end
