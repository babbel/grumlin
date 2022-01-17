# frozen_string_literal: true

module Grumlin
  module Expressions
    module U
      # TODO: add other start steps
      SUPPORTED_STEPS = %i[V addV coalesce constant count drop fold has hasLabel hasNot id identity in inE inV is label
                           out outE outV project repeat select timeLimit unfold valueMap values].freeze

      class << self
        SUPPORTED_STEPS.each do |step|
          define_method step do |*args, **params|
            AnonymousStep.new(step, *args, **params)
          end
        end
      end
    end
  end
end
