# frozen_string_literal: true

module Grumlin
  module Order
    # TODO: share the code?
    class << self
      %i[asc desc].each do |step|
        define_method step do
          name = "@#{step}"
          return instance_variable_get(name) if instance_variable_defined?(name)

          instance_variable_set(name, TypedValue.new(step, type: "Order"))
        end
      end
    end
  end
end
