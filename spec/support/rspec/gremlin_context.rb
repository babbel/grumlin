# frozen_string_literal: true

module RSpec
  module GremlinContext
  end

  RSpec.shared_context GremlinContext do
    include GremlinContext

    let(:url) { ENV["GREMLIN_URL"] }
    let!(:client) { Grumlin::Client.new(url) }
    let(:g) { Grumlin::Traversal.new(client) }

    after do
      client.disconnect
    end
  end
end
