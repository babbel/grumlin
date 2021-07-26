# frozen_string_literal: true

module Grumlin
  module Test
    module RSpec
      module GremlinContext
      end

      ::RSpec.shared_context GremlinContext do
        include GremlinContext

        let(:g) { Grumlin::Traversal.new }

        after do
          expect(Grumlin.config.default_client.requests).to be_empty
          Grumlin.config.default_client.disconnect
          Grumlin.config.reset!
        end
      end
    end
  end
end
