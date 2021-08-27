# frozen_string_literal: true

module Grumlin
  class Traversal
    attr_reader :connection

    # TODO: add other start steps
    SUPPORTED_START_STEPS = %w[E V addE addV].freeze

    def initialize(pool = Grumlin.config.default_pool)
      @pool = pool
    end

    SUPPORTED_START_STEPS.each do |step|
      define_method step do |*args|
        Step.new(@pool, step, *args)
      end
    end
  end
end
