# frozen_string_literal: true

module Grumlin
  module U
    # TODO: add other start steps
    SUPPORTED_START_STEPS = %i[V addV count fold has out repeat unfold values].freeze

    class << self
      SUPPORTED_START_STEPS.each do |step|
        define_method step do |*args|
          AnonymousStep.new(step, *args)
        end
      end
    end
  end
end
