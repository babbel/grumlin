# frozen_string_literal: true

module Grumlin
  # TODO: find a better name
  class TypedValue
    def initialize(value, type: nil)
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
    alias to_readable_bytecode inspect
  end
end
