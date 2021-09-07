# frozen_string_literal: true

module Grumlin
  # TODO: find a better name
  class TypedValue
    def initialize(type, value)
      @type = type
      @value = value
    end

    def to_bytecode
      @to_bytecode ||= { "@type": "g:#{@type}", "@value": @value }
    end

    def inspect
      "<#{@type}.#{@value}>"
    end
    alias to_s inspect
  end
end
