# frozen_string_literal: true

module Grumlin
  class Traversal
    # TODO: add other start steps
    SUPPORTED_STEPS = %i[E V addE addV].freeze

    def initialize(pool = Grumlin.default_pool)
      @pool = pool
    end

    SUPPORTED_STEPS.each do |step|
      define_method step do |*args|
        Step.new(@pool, step, *args)
      end
    end
  end
end
