# frozen_string_literal: true

module Grumlin
  module Tools
    module Order
      # TODO: share the code?
      SUPPORTED_STEPS = %i[asc desc].freeze

      class << self
        SUPPORTED_STEPS.each do |step|
          define_method step do
            name = "@#{step}"
            return instance_variable_get(name) if instance_variable_defined?(name)

            instance_variable_set(name, TypedValue.new(type: "Order", value: step))
          end
        end
      end
    end
  end
end
