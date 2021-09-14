# frozen_string_literal: true

module Grumlin
  # TODO: find a better name
  class TypedValue
    attr_reader :type, :value

    def initialize(type: nil, value: nil)
      @type = type
      @value = value
    end

    def to_bytecode
      @to_bytecode ||= {
        "@type": "g:#{type}",
        "@value": value
      }
    end

    def inspect
      "<#{type}.#{value}>"
    end
    alias to_s inspect
    alias to_readable_bytecode inspect
  end
end
