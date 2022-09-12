# frozen_string_literal: true

class Grumlin::Expressions::WithOptions
  WITH_OPTIONS = Grumlin.definitions.dig(:expressions, :with_options).freeze

  class << self
    WITH_OPTIONS.each do |k, v|
      define_method k do
        name = "@#{k}"
        return instance_variable_get(name) if instance_variable_defined?(name)

        instance_variable_set(name, WithOptions.new(k, v))
      end
    end
  end

  attr_reader :name, :value

  def initialize(name, value)
    @name = name
    @value = value
  end

  def to_s
    "WithOptions.#{@name}"
  end
end
