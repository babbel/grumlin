# frozen_string_literal: true

module Grumlin
  class Traversal
    attr_reader :connection

    def initialize(pool = Grumlin.config.default_pool)
      @pool = pool
    end

    # TODO: add other start steps
    %w[addV addE V E].each do |step|
      define_method step do |*args|
        Step.new(@pool, step, *args)
      end
    end

    alias addVertex addV
    alias addEdge addE
  end
end
