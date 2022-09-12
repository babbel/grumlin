# frozen_string_literal: true

module Grumlin::Test::RSpec
  module GremlinContext
  end

  ::RSpec.shared_context GremlinContext do
    include GremlinContext
    include Grumlin::Expressions

    [:__, :g].each do |name|
      define_method(name) do |cuts = Grumlin::Shortcuts::Storage.empty|
        cuts.send(name)
      end
    end

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
