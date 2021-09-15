# frozen_string_literal: true

module Grumlin
  class TypedValue
    attr_reader :type, :value

    def initialize(type: nil, value: nil)
      @type = type
      @value = value
    end

    def to_bytecode
      @to_bytecode ||= if type.nil?
                         value
                       else
                         {
                           "@type": "g:#{type}",
                           "@value": value
                         }
                       end
    end

    def inspect
      "<#{type}.#{value}>"
    end
    alias to_s inspect
    alias to_readable_bytecode inspect
  end
end
