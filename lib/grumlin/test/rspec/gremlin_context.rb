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
          Grumlin.config.default_pool.close
          Grumlin.config.reset!
        end
      end
    end
  end
end
