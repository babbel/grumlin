# frozen_string_literal: true

module Grumlin
  class TraversingContext
    T_ID = { :@type => "g:T", :@value => "id" }.freeze

    ORDER_DESC = { "@type": "g:Order", "@value": "desc" }.freeze
    ORDER_ASC = { "@type": "g:Order", "@value": "desc" }.freeze

    attr_reader :g

    def initialize(traversal)
      @g = traversal
    end

    def id
      T_ID
    end

    def asc
      ORDER_ASC
    end

    def desc
      ORDER_DESC
    end
  end
end
