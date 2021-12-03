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
          Grumlin::Expressions.constants.each do |tool|
            stub_const(tool.to_s, Grumlin::Expressions.const_get(tool))
          end
        end

        after do
          Grumlin.close
        end
      end
    end
  end
end
