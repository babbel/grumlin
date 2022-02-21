# frozen_string_literal: true

module Grumlin
  class TypedValue
    attr_reader :type, :value

    def initialize(type: nil, value: nil)
      @type = type
      @value = value
    end

    def inspect
      "<#{type}.#{value}>"
    end

    def to_s
      inspect
    end
  end
end
