# frozen_string_literal: true

module Grumlin
  module T
    # TODO: share the code?
    class << self
      %i[id label].each do |step|
        define_method step do
          name = "@#{step}"
          return instance_variable_get(name) if instance_variable_defined?(name)

          instance_variable_set(name, TypedValue.new(type: "T", value: step))
        end
      end
    end
  end
end
