# frozen_string_literal: true

module Grumlin::Expressions::Expression
  def define_steps(steps, tool_name)
    steps.each do |step|
      define_method step do
        name = "@#{step}"
        return instance_variable_get(name) if instance_variable_defined?(name)

        instance_variable_set(name, Grumlin::TypedValue.new(type: tool_name, value: step))
      end
    end
  end
end
