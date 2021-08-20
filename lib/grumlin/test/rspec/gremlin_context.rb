# frozen_string_literal: true

module Grumlin
  module Test
    module RSpec
      module GremlinContext
      end

      ::RSpec.shared_context GremlinContext do
        include GremlinContext
        include Grumlin::Sugar

        before do
          Grumlin::Sugar::HELPERS.each do |helper|
            name = helper.name.split("::").last
            stub_const(name, helper)
          end
        end

        after do
          Grumlin.config.default_pool.close
          Grumlin.config.reset!
        end
      end
    end
  end
end
