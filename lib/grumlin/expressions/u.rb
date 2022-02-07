# frozen_string_literal: true

module Grumlin
  module Expressions
    # The module is called U because Underscore and implements __
    module U
      class << self
        Grumlin::Step::SUPPORTED_STEPS.each do |step|
          define_method step do |*args, **params|
            Step.new(step, *args, **params)
          end
        end
      end
    end
  end
end
