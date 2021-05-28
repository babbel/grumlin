# frozen_string_literal: true

module Grumlin
  class TraversingContext
    ORDER_DESC = { "@type": "g:Order", "@value": "desc" }.freeze
    ORDER_ASC = { "@type": "g:Order", "@value": "desc" }.freeze

    attr_reader :g

    def initialize(traversal)
      @g = traversal
    end

    def asc
      ORDER_ASC
    end

    def desc
      ORDER_DESC
    end

    def self.V(id) # rubocop:disable Naming/MethodName
      { "@type": "g:Bytecode", "@value": { step: [["V", { "@type": "g:Int32", "@value": id }]] } }
    end
  end
end
