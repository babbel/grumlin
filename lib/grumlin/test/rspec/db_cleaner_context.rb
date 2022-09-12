# frozen_string_literal: true

module Grumlin::Test::RSpec
  module DBCleanerContext
  end

  ::RSpec.shared_context DBCleanerContext do
    include DBCleanerContext

    before do
      g.E.drop.iterate
      g.V.drop.iterate
    end
  end
end
