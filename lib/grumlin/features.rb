# frozen_string_literal: true

module Grumlin::Features
  class << self
    FEATURES = {
      neptune: NeptuneFeatures.new,
      tinkergraph: TinkergraphFeatures.new
    }.freeze

    def for(provider)
      FEATURES[provider]
    end
  end
end
