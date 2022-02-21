# frozen_string_literal: true

module Grumlin
  module Expressions
    # The module is called U because Underscore and implements __
    module U
      class << self
        Grumlin::AnonymousStep::SUPPORTED_STEPS.each do |step|
          define_method step do |*args, **params|
            Action.new(step, args: args, params: params)
          end
        end
      end
    end
  end
end
