# frozen_string_literal: true

module Grumlin
  module Expressions
    module WithOptions
      WITH_OPTIONS = {
        tokens: "~tinkerpop.valueMap.tokens",
        none: 0,
        ids: 1,
        labels: 2,
        keys: 4,
        values: 8,
        all: 15,
        indexer: "~tinkerpop.index.indexer",
        list: 0,
        map: 1
      }.freeze

      class << self
        WITH_OPTIONS.each do |k, v|
          define_method k do
            v
          end
        end
      end
    end
  end
end
