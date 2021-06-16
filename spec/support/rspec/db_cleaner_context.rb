# frozen_string_literal: true

module RSpec
  module DBCleanerContext
  end

  RSpec.shared_context DBCleanerContext do
    include DBCleanerContext

    before do
      client = Grumlin::Client.new(ENV["GREMLIN_URL"])
      Grumlin::Traversal.new(client).V().drop.iterate
      client.disconnect
    end
  end
end
